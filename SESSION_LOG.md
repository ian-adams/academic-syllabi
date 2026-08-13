# Session Log

## Session: 2026-08-13 12:30

### Completed

Rebuilt CRJU 314 (Criminal Law) for Fall 2026 as a fully asynchronous online
section. Committed as `ef67c4e`, pushed to `origin/main`.

- **New textbook.** Lippman, *Contemporary Criminal Law* on SAGE Vantage
  (ISBN 9798348809096, Inclusive Access, opt-out deadline Sept 1). Replaces
  Garland 5e. Packback and the *Serial* podcast dropped.
- **Data-driven schedule and weights.** Both derive from the Vantage
  assignment export at knit time rather than being typed in, so the syllabus
  cannot drift from the live course. Weights: Chapter Learning Activities 30%,
  Knowledge Checks 20%, Chapter Quizzes 14%, Final Exam 36%.
- **Thanksgiving restructure.** Original Vantage dates put Ch. 15 and 16 both
  inside Thanksgiving recess and left the last week of classes empty. Moved
  Ch. 15 back to join Ch. 14 (Nov 22) and Ch. 16 forward to Fri Dec 4.
- **Final exam.** Dec 7, 8:00–11:59 a.m., 120 questions x 5 pts, 120-minute
  timer, auto-submits with unanswered questions scored zero.
- **Policy additions.** Boxed no-late-work notice on page 1; contextual-use
  GenAI policy; traditional A−/B−/C− grading scale.
- **ACAF 2.03 / CTE compliance.** Added every required section the Fall 2023
  version predated and refreshed dead student-resource links.
- **Three output formats from one source** via `build.R`.

### Key Decisions

- **Grading weights show percentages only, no point values.** Instructor
  preference — students track running totals in Vantage/Blackboard. Category
  weights are still stated because ACAF 2.03 requires them.
- **Traditional grading scale over USC's suggested scale.** USC permits
  instructor-entered minus grades; the suggested 89.5% = A scale was judged
  inflationary. A now starts at 93%, A− at 90%.
- **Single-morning final exam window retained** despite CTE guidance favoring
  multi-day windows for asynchronous courses. Instructor confirmed as
  intentional; syllabus carries explicit time-zone and latest-start warnings.
- **Excused-absence carve-out kept** in the late-work box as a footnote. USC's
  attendance policy obliges instructors to honor Student Advocacy
  certifications, so an unqualified "no exceptions" would be a grade-appeal
  exposure.
- **Word chosen as the Blackboard upload.** HTML scores best with Ally, but
  this Blackboard install blocks `.html` uploads at the server policy level.

### Notes for next time

- **`stevetemplates` is broken under Pandoc 3.x.** `template.tex:121`
  redefines `\includegraphics` to take no optional argument, and the template
  never defines `\pandocbounded`. Shims live in `latex-preamble.tex`. **Other
  syllabi in this repo will hit the same wall on their next knit.**
- `stevemisc` is not installed on this machine. Only the attendance-regression
  chunk needed it; dropped.
- The Vantage export does **not** include the Blackboard final exam. It is
  defined in the setup chunk (`final_questions` x `final_per_q`), and a filter
  drops any stray `Final` placeholder row so it cannot be double-counted.
- `build.R` strips inline JavaScript from the HTML build and hard-fails if any
  survives; it also patches real alt text into the Word calendar image, since
  knitr's `fig.alt` is unsupported for docx.

### Next Steps

- Upload `CRJU-314-Fall-2026.docx` to Blackboard; keep the PDF as the
  printable copy.
- Confirm the Blackboard final-exam item matches the syllabus: Dec 7,
  8:00–11:59 a.m., 120 questions at 5 points, 120-minute timer. The old
  Vantage placeholder was dated 12/27 and worth 150.
- Re-export from Vantage and re-knit if any due date changes; the invariant
  checks will stop the build if a change breaks the schedule design.
