(require 'cl-lib)

(defvar *container-tags*
  '("a" "article"  "aside" "b" "body" "canvas" "dd" "div" "dl" "dt" "em" "fieldset"
    "footer" "form" "h1" "h2" "h3" "h4" "h5" "h6" "head" "header" "hgroup" "html"
    "i" "iframe" "label" "li" "nav" "ol" "option" "pre" "section" "script" "span"
    "strong" "style" "table" "textarea" "title" "ul"))

(defun html-compile (sexp)
  "Convert ELisp s-exp to html string"
  (with-output-to-string
    (cl-labels
	((loop-sexp (x)
		    (cond
		     ((listp x)
		      (let ((name (symbol-name (car x)))
			    (attrs '())
			    (content '()))
			(if (and (listp (cdr x))
				 (or (eq nil (cadr x))
				     (and (listp (cadr x))
					  (listp
					   (car (car (cdr x)))))))
			    (progn
			      (setq attrs (cadr x))
			      (setq content (cddr x)))
			  (progn
			    (setq attrs nil)
			    (setq content (cdr x))))
			(princ "<")

			;;class sugar
			(if (> (length (split-string name "\\.")) 1)
			    (progn 
			      (let ((name-list (split-string name "\\.")))
				(setq name (car name-list))
				(princ name)
				(princ " class=\"")
				(if (car (cdr name-list))
				    (princ (car (cdr name-list))))
				(dolist (elem (cdr (cdr name-list)))
				  (princ " ")
				  (princ  elem))
				)
			      (princ "\""))
			  (princ name))

			(dolist (elem attrs)
			  (princ " " )
			  (princ (symbol-name (car elem)))
			  (princ "=\"" )
			  (princ (cadr elem))
			  (princ "\"" ))
			(if (and (not (member name *container-tags*)) (eq content nil))
			    (princ " />")
			  (progn
			    (princ ">")
			    (dolist (exp content)
			      (loop-sexp exp))
			    (princ "</" )
			    (princ name )
			    (princ ">" )))))
		     ((stringp x)
		      (princ x ))
		     ((symbolp x)
		      (princ "&" )
		      (princ (symbol-name x))
		      (princ ";" )))))
      (loop-sexp sexp))))
