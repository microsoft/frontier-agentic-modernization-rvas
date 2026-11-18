using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using MinimalApi.Endpoint;

namespace Microsoft.eShopWeb.PublicApi.CatalogItemEndpoints;

/// <summary>
/// Creates a new Catalog Item
/// </summary>
public class CreateCatalogItemEndpoint : IEndpoint<IResult, CreateCatalogItemRequest, IRepository<CatalogItem>>
{
    private readonly IUriComposer _uriComposer;
    private readonly ICatalogItemAiService _aiService;

    public CreateCatalogItemEndpoint(IUriComposer uriComposer, ICatalogItemAiService aiService)
    {
        _uriComposer = uriComposer;
        _aiService = aiService;
    }

    public void AddRoute(IEndpointRouteBuilder app)
    {
        app.MapPost("api/catalog-items",
            [Authorize(Roles = BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS, AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)] async
            (CreateCatalogItemRequest request, IRepository<CatalogItem> itemRepository) =>
            {
                return await HandleAsync(request, itemRepository);
            })
            .Produces<CreateCatalogItemResponse>()
            .WithTags("CatalogItemEndpoints");
    }

    public async Task<IResult> HandleAsync(CreateCatalogItemRequest request, IRepository<CatalogItem> itemRepository)
    {
        var response = new CreateCatalogItemResponse(request.CorrelationId());

        var catalogItemNameSpecification = new ApplicationCore.Specifications.CatalogItemNameSpecification(request.Name);
        var existingCataloogItem = await itemRepository.CountAsync(catalogItemNameSpecification);
        if (existingCataloogItem > 0)
        {
            throw new ApplicationCore.Exceptions.DuplicateException($"A catalogItem with name {request.Name} already exists");
        }

        // If an image was provided but no description, ask AI to suggest one
        if (!string.IsNullOrWhiteSpace(request.PictureBase64) && string.IsNullOrWhiteSpace(request.Description))
        {
            var imageBytes = Convert.FromBase64String(request.PictureBase64);
            var suggestion = await _aiService.SuggestAsync(imageBytes, "image/png", request.Name);
            if (suggestion != null)
            {
                request.Description = suggestion.Description;
            }
        }

        var newItem = new CatalogItem(request.CatalogTypeId, request.CatalogBrandId, request.Description, request.Name, request.Price, request.PictureUri);
        newItem = await itemRepository.AddAsync(newItem);

        if (newItem.Id != 0)
        {
            //We disabled the upload functionality and added a default/placeholder image to this sample due to a potential security risk 
            //  pointed out by the community. More info in this issue: https://github.com/dotnet-architecture/eShopOnWeb/issues/537 
            //  In production, we recommend uploading to a blob storage and deliver the image via CDN after a verification process.

            newItem.UpdatePictureUri("eCatalog-item-default.png");
            await itemRepository.UpdateAsync(newItem);
        }

        var dto = new CatalogItemDto
        {
            Id = newItem.Id,
            CatalogBrandId = newItem.CatalogBrandId,
            CatalogTypeId = newItem.CatalogTypeId,
            Description = newItem.Description,
            Name = newItem.Name,
            PictureUri = _uriComposer.ComposePicUri(newItem.PictureUri),
            Price = newItem.Price
        };
        response.CatalogItem = dto;
        return Results.Created($"api/catalog-items/{dto.Id}", response);
    }
}
