using System.Collections.Generic;

namespace ContosoUniversity.Models
{
    /// <summary>
    /// AI-generated suggestions for a course based on a teaching-material image.
    /// </summary>
    public class CourseAiSuggestion
    {
        public string Description { get; set; }
        public IList<string> LearningObjectives { get; set; }
        public string AltText { get; set; }
    }
}
