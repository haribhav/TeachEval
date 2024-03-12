// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Smart Contract for TeachEval with ID-based system
/// @author Manav Vagdoda

contract TeachEval {
    // Define a struct for Course
    struct Course {
        uint courseId;
        address professor;  // Changed from uint to address for direct association
        bool isAssigned;
        uint16 studentCount;
        address[] students;  // Keep track of enrolled students
        mapping(address => uint8[10]) reviews;  // Each student can submit a review (array of 10 ratings)
    }

    // Define a struct for Professor
    struct Professor {
        address professor;  // Changed from uint to address
        uint[] coursesTaught;  // List of courseIds a professor has taught
    }

    // State variables
    mapping(uint => Course) public courses;  // Mapping of courseId to Course struct
    mapping(address => Professor) private professors;  // Mapping of professor address to Professor struct
    mapping(address => uint[]) private studentCourses;  // Mapping of student address to courseIds

    uint private nextCourseId = 1;

    // Events
    event CourseAssigned(uint courseId, address professor);
    event StudentEnrolled(uint courseId, address student);
    event ReviewSubmitted(uint courseId, address student);

    // Modifiers
    modifier onlyProfessor() {
        require(professors[msg.sender].professor == msg.sender, "Not a registered professor");
        _;
    }

    modifier courseExists(uint courseId) {
        require(courses[courseId].courseId == courseId, "Course does not exist");
        _;
    }

    // Functions
    // Explicit getter function for professor's courses
    function getProfessorCourses() external view returns (uint[] memory) {
        require(professors[msg.sender].professor == msg.sender, "Not a registered professor");
        return professors[msg.sender].coursesTaught;
    }

    // Explicit getter function for student's enrolled courses
    function getStudentCourses() external view returns (uint[] memory) {
        return studentCourses[msg.sender];
    }

    // Function for a professor to choose a course
    function chooseCourse(uint courseId) external onlyProfessor {
        require(!courses[courseId].isAssigned, "Course already assigned");
        courses[courseId].professor = msg.sender;
        courses[courseId].isAssigned = true;
        professors[msg.sender].coursesTaught.push(courseId);
        emit CourseAssigned(courseId, msg.sender);
    }

    // Function for a student to enroll in a course
    function enrollCourse(uint courseId) external courseExists(courseId) {
        require(courses[courseId].studentCount < 30, "Course is full");
        courses[courseId].studentCount++;
        studentCourses[msg.sender].push(courseId);
        courses[courseId].students.push(msg.sender);
        emit StudentEnrolled(courseId, msg.sender);
    }

    // Function for a student to submit a review
    function submitReview(uint courseId, uint8[10] memory ratings) external courseExists(courseId) {
        require(isStudentEnrolled(msg.sender, courseId), "Student not enrolled in course");
        courses[courseId].reviews[msg.sender] = ratings;
        emit ReviewSubmitted(courseId, msg.sender);
    }   

    // Function for a professor to view average review of a course
    function viewReview(uint courseId) external view onlyProfessor courseExists(courseId) returns (uint8[10] memory) {
        require(courses[courseId].professor == msg.sender, "Not the course professor");
        uint8[10] memory averageRatings;
        uint256 totalStudents = courses[courseId].studentCount;
        address[] memory enrolledStudents = courses[courseId].students;

        for(uint i = 0; i < 10; i++) {
            uint256 totalRating = 0;
            for(uint j = 0; j < totalStudents; j++) {
                address student = enrolledStudents[j];
                totalRating += courses[courseId].reviews[student][i];
            }
            averageRatings[i] = uint8(totalRating / totalStudents);
        }
        return averageRatings;
    }

    // Helper function to check if a student is enrolled in a course
    function isStudentEnrolled(address student, uint courseId) internal view returns (bool) {
        for(uint i = 0; i < studentCourses[student].length; i++) {
            if(studentCourses[student][i] == courseId) {
                return true;
            }
        }
        return false;
    }
}