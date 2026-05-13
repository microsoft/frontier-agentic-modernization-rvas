using System.IO;
using System.Threading;
using System.Threading.Tasks;
using ContosoUniversity.Models;

namespace ContosoUniversity.Services
{
    /// <summary>
    /// Analyzes a teaching-material image with Azure OpenAI (vision) and returns
    /// suggested course description, learning objectives, and alt text.
    /// Implementations must never throw – they return null on failure so that the
    /// caller can continue persisting the course without AI fields.
    /// </summary>
    public interface ICourseContentAiService
    {
        Task<CourseAiSuggestion> AnalyzeAsync(byte[] imageBytes, string mimeType, string courseTitle, CancellationToken ct = default);
    }
}
