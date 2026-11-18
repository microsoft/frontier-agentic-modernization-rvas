using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ContosoUniversity.Models
{
    public class Course
    {
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [Display(Name = "Number")]
        public int CourseID { get; set; }

        [StringLength(50, MinimumLength = 3)]
        public string Title { get; set; }

        [Range(0, 5)]
        public int Credits { get; set; }

        public int DepartmentID { get; set; }

        [Display(Name = "Teaching Material Image")]
        [StringLength(255)]
        public string TeachingMaterialImagePath { get; set; }

        [Display(Name = "Description")]
        [StringLength(2000)]
        public string Description { get; set; }

        [Display(Name = "Learning Objectives")]
        [StringLength(2000)]
        public string LearningObjectives { get; set; }

        [Display(Name = "Alt Text")]
        [StringLength(500)]
        public string AltText { get; set; }

        public virtual Department Department { get; set; }
        public virtual ICollection<Enrollment> Enrollments { get; set; }
        public virtual ICollection<CourseAssignment> CourseAssignments { get; set; }
    }
}
