;;;; demo.lisp - menu for our live presentation
;;;;
;;;; Run it from the repo root with:
;;;;     sbcl --script demo.lisp
;;;;
;;;; This file is only a presentation helper. All the graded functions are in
;;;; Project3/Computa_project3.lisp and this just calls them. Like tests.lisp,
;;;; it uses normal Lisp tools (LOOP, FORMAT, READ, TRACE) to run the menu.

;; Loading prints harmless "undefined function" style warnings (functions that
;; call ones further down the file), so we hide warnings while loading.
(defvar *demo-dir* *load-truename*)

(defun quiet-load (file)
  (handler-bind ((warning #'muffle-warning))
    (load (merge-pathnames file *demo-dir*))))

(quiet-load "Project3/Computa_project3.lisp")

;; dataset from the project handout
(defparameter *students*
  '((101 (1 85) (2 90) (3 78))
    (102 (1 92) (3 88))
    (103 (2 75) (3 95))
    (104 (1 80) (2 85))))

(defparameter *function-names*
  (list (cons #'< "#'<") (cons #'> "#'>") (cons #'<= "#'<=") (cons #'>= "#'>=")))


;;; ------------------------------------------------------------
;;; Input and output helpers
;;; ------------------------------------------------------------

(defun prompt-line (text)
  "Prints TEXT and reads one line. Quits the demo cleanly at end of input."
  (format t "~a" text)
  (finish-output)
  (let ((line (read-line *standard-input* nil :eof)))
    (when (eq line :eof) (throw 'quit nil))
    (string-trim '(#\Space #\Tab #\Return) line)))

(defun prompt-value (text default)
  "Reads one Lisp value like (1 2 3), 101 or t. Blank line uses DEFAULT."
  (loop
    (let ((line (prompt-line (format nil "  ~a [Enter = ~(~s~)]: " text default))))
      (if (string= line "")
          (return default)
          (handler-case (let ((*read-eval* nil))
                          (return (read-from-string line)))
            (error ()
              (format t "  Couldn't read that. Try something like (1 2 3).~%")))))))

(defun prompt-list (text default)
  (loop
    (let ((value (prompt-value text default)))
      (if (listp value)
          (return value)
          (format t "  That needs to be a list, like (1 2 3).~%")))))

(defun show-arg (x)
  "How an argument is shown on screen, written the way you'd type it."
  (cond ((eq x *students*) "students")
        ((functionp x) (or (cdr (assoc x *function-names*)) "#'<lambda>"))
        ((null x) "'()")
        ((or (consp x) (and (symbolp x) (not (eq x t)))) (format nil "'~(~s~)" x))
        (t (format nil "~(~s~)" x))))

(defun show-call (fn &rest args)
  "Calls FN on ARGS and prints the call and its result."
  (let ((result (handler-case (apply fn args)
                  (error (e) (format nil "ERROR: ~a" e)))))
    (format t "  (~(~a~)~{ ~a~})~%      => ~(~s~)~%" fn (mapcar #'show-arg args) result)
    result))

(defun header (title)
  (format t "~%~a~%~a~%" title (make-string (length title) :initial-element #\=)))

(defun note (text &rest args)
  (format t "~%  ~?~%" text args))

(defun pause ()
  (prompt-line (format nil "~%Press Enter to go back to the menu...")))


;;; ------------------------------------------------------------
;;; 1. Set operations
;;; ------------------------------------------------------------

(defun demo-sets ()
  (header "Section 3: Set Operations")
  (note "Sets are plain lists with no duplicates. Press Enter to use the handout example.")
  (let ((a (prompt-list "set-1" '(1 2 3)))
        (b (prompt-list "set-2" '(2 4)))
        (item (prompt-value "item for set-member" 2)))
    (terpri)
    (show-call 'set-member a item)
    (show-call 'set-union a b)
    (show-call 'set-intersection a b)
    (show-call 'set-diff a b)
    (show-call 'set-symmetric-diff a b)
    (note "set-1 is still ~(~s~) and set-2 is still ~(~s~). Nothing was changed." a b))
  (pause))


;;; ------------------------------------------------------------
;;; 2. Boolean logic
;;; ------------------------------------------------------------

(defun only-t-and-nil-p (exp)
  "True if EXP has no variables, so boolean-eval can work it out."
  (cond ((null exp) t)
        ((eq exp t) t)
        ((consp exp) (every #'only-t-and-nil-p (cdr exp)))
        (t nil)))

(defun demo-boolean ()
  (header "Section 4: Boolean Logic")
  (note "Truth table for boolean-xor, boolean-implies and boolean-iff:")
  (format t "~%    A     B     |  xor   implies  iff~%")
  (format t "    ----------------------------------~%")
  (dolist (a '(t nil))
    (dolist (b '(t nil))
      (format t "    ~(~5a ~5a~) |  ~(~5a ~8a ~5a~)~%"
              a b (boolean-xor a b) (boolean-implies a b) (boolean-iff a b))))
  (note "boolean-eval works out an expression made of t and nil:")
  (let ((exp (prompt-value "expression" '(implies (and t nil) (or nil t)))))
    (if (only-t-and-nil-p exp)
        (show-call 'boolean-eval exp)
        (format t "  That has variables in it, so it can't be evaluated. Try simplify below.~%")))
  (note "boolean-simplify cleans up an expression. Variables like a and b are allowed:")
  (let ((exp (prompt-value "expression" '(or (and (not (not a)) t) (and b nil)))))
    (show-call 'boolean-simplify exp))
  (pause))


;;; ------------------------------------------------------------
;;; 3. List processing
;;; ------------------------------------------------------------

(defun demo-lists ()
  (header "Section 5: Recursive List Processing")
  (let ((lst (prompt-list "list" '(1 2 3 2 1))))
    (terpri)
    (show-call 'list-reverse lst)
    (show-call 'list-remove-duplicates lst)
    (show-call 'list-palindrome lst))
  (note "list-flatten takes a nested list:")
  (let ((nested (prompt-list "nested list" '(1 (2 (3 4)) 5))))
    (show-call 'list-flatten nested))
  (pause))


;;; ------------------------------------------------------------
;;; 4. Merge sort
;;; ------------------------------------------------------------

(defun demo-merge-sort ()
  (header "Section 6: Merge Sort")
  (let ((lst (prompt-list "list to sort" '(5 1 4 1 5 9 2 6))))
    (note "Same list, different predicates:")
    (show-call 'merge-sort lst #'<)
    (show-call 'merge-sort lst #'>)
    (show-call 'merge-sort lst #'<=)
    (note "How it splits the list (1st, 3rd, 5th... left and 2nd, 4th, 6th... right):")
    (show-call 'merge-sort-split lst)
    (note "The original list is still ~(~s~). Duplicates are kept." lst))
  (note "Any predicate works. Sorting (course grade) pairs by grade:")
  (format t "~%  (merge-sort '((1 85) (2 90) (3 78))~%")
  (format t "              (lambda (a b) (< (second a) (second b))))~%")
  (format t "      => ~(~s~)~%"
          (merge-sort '((1 85) (2 90) (3 78))
                      (lambda (a b) (< (second a) (second b)))))
  (pause))


;;; ------------------------------------------------------------
;;; 5. Student Course Analyzer
;;; ------------------------------------------------------------

(defun print-student-table ()
  (format t "~%    Student | Courses (course: grade)~%")
  (format t "    --------+-------------------------------~%")
  (dolist (record *students*)
    (format t "    ~7a |~{ ~{~a: ~a~}~^,~}~%" (first record) (rest record))))

(defun demo-analyzer ()
  (header "Section 7: Student Course Analyzer")
  (print-student-table)
  (note "Pick two students:")
  (let ((s1 (prompt-value "first student id" 101))
        (s2 (prompt-value "second student id" 104)))
    (terpri)
    (dolist (id (list s1 s2))
      (show-call 'get-student-courses *students* id)
      (if (get-student-courses *students* id)
          (let ((avg (show-call 'student-average *students* id)))
            (format t "      (that's ~,2f)~%" avg))
          (format t "  Student ~a isn't in the list, so there's no average.~%" id)))
    (note "Shared courses (reuses set-intersection and list-remove-duplicates):")
    (show-call 'common-courses *students* s1 s2))
  (note "Ranking students by average with merge-sort and our own predicate:")
  (let ((ranked (merge-sort (list 101 102 103 104)
                            (lambda (a b)
                              (> (student-average *students* a)
                                 (student-average *students* b))))))
    (format t "~%  (merge-sort '(101 102 103 104)~%")
    (format t "              (lambda (a b) (> (student-average students a)~%")
    (format t "                               (student-average students b))))~%")
    (format t "      => ~a~%~%" ranked)
    (let ((place 0))
      (dolist (id ranked)
        (format t "    ~a. student ~a  average ~,2f~%"
                (incf place) id (student-average *students* id)))))
  (pause))


;;; ------------------------------------------------------------
;;; 6. Watch the recursion
;;; ------------------------------------------------------------

(defun watch (fn-names fn &rest args)
  "Turns on TRACE for FN-NAMES, runs the call so every recursive step is
printed with its depth, then turns TRACE back off."
  (eval `(trace ,@fn-names))
  (format t "~%")
  (unwind-protect
       (let ((*trace-output* *standard-output*))
         (apply fn args))
    (eval `(untrace ,@fn-names))))

(defun demo-recursion ()
  (header "Watch the Recursion")
  (format t "  Each line is one call. The number and indent show how deep it is.~%~%")
  (format t "  1) list-flatten      on (1 (2 (3 4)) 5)~%")
  (format t "  2) merge-sort        on (3 1 4 2)~%")
  (format t "  3) set-member        on (1 2 3) looking for 3~%")
  (format t "  4) boolean-simplify  on (and (or a nil) t)~%")
  (format t "  5) common-courses    for students 101 and 104~%")
  (let ((choice (prompt-line (format nil "~%  Pick one: "))))
    (cond ((string= choice "1") (watch '(list-flatten) 'list-flatten '(1 (2 (3 4)) 5)))
          ((string= choice "2") (watch '(merge-sort merge-sort-merge) 'merge-sort '(3 1 4 2) #'<))
          ((string= choice "3") (watch '(set-member) 'set-member '(1 2 3) 3))
          ((string= choice "4") (watch '(boolean-simplify) 'boolean-simplify '(and (or a nil) t)))
          ((string= choice "5") (watch '(common-courses get-student-courses
                                         list-remove-duplicates set-intersection)
                                       'common-courses *students* 101 104))
          (t (format t "  Pick 1 to 5.~%"))))
  (pause))


;;; ------------------------------------------------------------
;;; 7. Test suite
;;; ------------------------------------------------------------

(defun demo-tests ()
  (header "Test Suite")
  ;; tests.lisp keeps running totals, so reset them if it was run before
  (when (boundp '*tests-run*)
    (setf (symbol-value '*tests-run*) 0
          (symbol-value '*tests-passed*) 0))
  (let* ((show-all (string-equal (prompt-line "  Show every test? (y/n) [Enter = n]: ") "y"))
         (output (with-output-to-string (*standard-output*)
                   (quiet-load "Project3/tests.lisp"))))
    (with-input-from-string (in output)
      (loop for line = (read-line in nil)
            while line
            when (or show-all
                     (search "===" line)
                     (search "[FAIL]" line)
                     (search "tests passed" line)
                     (search "TESTS" line))
              do (write-line line))))
  (pause))


;;; ------------------------------------------------------------
;;; Main menu
;;; ------------------------------------------------------------

(defun main-menu ()
  (loop
    (header "Computa - Project 3 Demo")
    (format t "  1) Set operations~%")
    (format t "  2) Boolean logic~%")
    (format t "  3) List processing~%")
    (format t "  4) Merge sort~%")
    (format t "  5) Student Course Analyzer~%")
    (format t "  6) Watch the recursion~%")
    (format t "  7) Run the test suite~%")
    (format t "  0) Quit~%")
    (let ((choice (prompt-line "> ")))
      (cond ((string= choice "1") (demo-sets))
            ((string= choice "2") (demo-boolean))
            ((string= choice "3") (demo-lists))
            ((string= choice "4") (demo-merge-sort))
            ((string= choice "5") (demo-analyzer))
            ((string= choice "6") (demo-recursion))
            ((string= choice "7") (demo-tests))
            ((member choice '("0" "q" "quit") :test #'string-equal) (return))
            (t (format t "Pick a number from the menu.~%"))))))

(catch 'quit (main-menu))
(format t "~%Thanks for watching!~%")
