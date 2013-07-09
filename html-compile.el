(require 'cl-lib)
(defvar my-sexpr '(span ((id "my-id")) "some content"))

(defvar *container-tags*
  '("a" "article"  "aside" "b" "body" "canvas" "dd" "div" "dl" "dt" "em" "fieldset"
    "footer" "form" "h1" "h2" "h3" "h4" "h5" "h6" "head" "header" "hgroup" "html"
    "i" "iframe" "label" "li" "nav" "ol" "option" "pre" "section" "script" "span"
    "strong" "style" "table" "textarea" "title" "ul"))

(defun html-compile (sexp)
  "Convert ELisp s-exp to html string"
  (let ((html-string ""))
    (cl-labels
	((loop-sexp (x)
		    (cond
		     ((listp x)
		      (let ((name (symbol-name (car x)))
			    (attrs '())
			    (content '()))
			(if (and (listp (cdr x))
				 (or (eq nil (cadr x))
				     (and (listp (cadr x)) (listp (caadr x)))))
			    (progn
			      (setq attrs (cadr x))
			      (setq content (cddr x)))
			  (progn
			    (setq attrs nil)
			    (setq content (cdr x))))
			(setq html-string (concat html-string "<"))
			(setq html-string (concat html-string name))
			(dolist (elem attrs html-string)
			  (setq html-string (concat html-string " "))
			  (setq html-string (concat html-string (symbol-name (car elem))))
			  (setq html-string (concat html-string "=\""))
			  (setq html-string (concat html-string (cadr elem)))
			  (setq html-string (concat html-string "\"")))
			(if (and (not (member name *container-tags*)) (eq content nil))
			    (setq html-string (concat html-string " />"))
			  (progn
			    (setq html-string (concat html-string ">"))
			    (dolist (exp content html-string)
			      (loop-sexp exp))
			    (setq html-string (concat html-string "</"))
			    (setq html-string (concat html-string name))
			    (setq html-string (concat html-string ">"))))))
		     ((stringp x)
		      (setq html-string (concat html-string x)))
		     ((symbolp x)
		      (setq html-string (concat html-string "&"))
		      (setq html-string (concat html-string (symbol-name x)))
		      (setq html-string (concat html-string ";"))))))
      (loop-sexp sexp))
    html-string))

(html-compile '(span ((id "my-id")) (p "this is a paragraph")))
(html-compile '(html (body (p "para a") nbsp (p "para b"))))
(defvar a-name "John")
(cl-assert (equal "<html><head><title>Welcome</title></head><body><p>Hello John</p></body></html>"
		  (html-compile `(html (head (title "Welcome"))
				       (body (p ,(concat "Hello " a-name)))))))
(cl-assert (equal "<p />" (html-compile '(p))))
(cl-assert (equal "<script></script>" (html-compile '(script))))
(cl-assert (equal "<textarea></textarea>" (html-compile '(textarea))))
