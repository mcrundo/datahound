# Software Engineer - Technical Coding Exercise

This technical coding exercise consists of two phases designed to evaluate your ability to build, architect, and collaborate on a software project.

## Phase 1: Take-Home Exercise

**Objective:** Create a Dockerized Ruby on Rails application that handles the import and display of the CSV data in the `quotes.csv` file. Your code should be **production quality**, please don't submit the first thing that works. Spend some time thinking about the architecture and design as though this is the basis of a long term effort.

### Requirements

1.  **Project Setup:**
    *   Initialize a new **Ruby on Rails** application.
    *   The application **must** be containerized using **Docker** and **Docker Compose**. We should be able to spin up the entire stack with a single command (e.g., `docker compose up`).
    *   The application should use PostgreSQL for the database.

2.  **Feature: Data Import:**
    *   Implement a web interface to upload the included `quotes.csv` file.
    *   Parse the CSV and store the quote data in the database.
	*   Dig into and understand the data in the CSV. This data's structure should inform your how you model and present the data.
	*   The import process should be efficient and support large (500MB+) uploads.
	*   Your solution should gracefully handle multiple uploads of the same file / duplicative data.

3.  **Feature: Data Display:**
    *   Create a simple view to list the imported quote records.
    *   Display all columns using the header names in the CSV.
	*   View rendering should be efficient regardless of the total number of records.

4.  **Quality & Best Practices:**
    *   Write tests for your logic. As noted above we want to get a sense of what you feel **production quality** code looks like so please test accordingly.
    *   Ensure the code is clean, readable, and idiomatic.
	*   Ensure your solution is well architected / structured for future growth.
	*   Use Git in an appropriate manner.
    *   Include a `README.md` with clear instructions on how to build, run, and test your application.

### Bonus (optional)

**Additional features:**
*   Filtering, sorting, or grouping the displayed data in a way that's useful.
*   Derived or computed values surfaced in the UI (think about what a user would actually want to know from this data beyond a raw list).
*   Anything else you think would make this genuinely useful to a business user.

### Submission

Once you’ve completed Phase 1, please submit your project for review by emailing a ZIP file containing the project Git repository w/ the history intact.

We’ll review your submission and follow up regarding scheduling Phase 2.

---

## Phase 2: Technical Interview & Live Coding Exercise (90 minutes)

**Objective:** collaborate with a Lead Engineer to extend the application you built in Phase 1.

**What to expect:**
*   This phase will begin with some technical questions and then transition into the live coding exercise.
*   We will assume your Phase 1 submission is the starting point of the live coding exercise.
*   We will work together to implement a new feature or requirement on top of your existing code.
*   The goal is to assess your collaboration style, problem-solving process, and how you navigate and modify your own codebase.

**Preparation:**
*   Have your development environment ready and running before the call.
*   Be prepared to share your screen and explain your architectural decisions from Phase 1.
