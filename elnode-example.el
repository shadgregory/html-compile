(require 'elnode)
(load-file "html-compile.el")

(defadvice elnode-http-return (around elnode-around activate)
  (if (listp (ad-get-arg 1))
      (ad-set-arg 1 (html-compile (ad-get-arg 1))))
  ad-do-it)

(ad-activate 'elnode-http-return)

(defun about-elnode-handler (httpcon)
   (elnode-http-start httpcon 200 '("Content-Type" . "text/html"))
   (elnode-http-return 
       httpcon 
       '(html (head (title "Shad's Elnode Server")) 
	      (body ((bgcolor "#e5e5e5")) 
		    (p ((style "text-align:center;")) 
		       (a ((href "https://github.com/nicferrier/elnode")) "Elnode") " rocks!")
		    (p 
		       (form ((style "text-align:center;") (action "name"))
			     (label ((for "name")) "What is your name?") nbsp (input ((type "text") (name "name")))
			     (input ((type "submit") (value "Greet")))))))))

(defun hello-name-handler (httpcon)
  (elnode-http-start httpcon 200 '("] Content-Type" . "text/html"))
  (let ((a-name (elnode-http-param httpcon "name")))
    (if (eq a-name nil)
	(setq a-name "John Thomas"))
    (elnode-http-return httpcon `(html 
				  (body ((bgcolor "#e5e5e5")) 
					(h1 ((style "text-align:center;"))
					 ,(concat "Hello " a-name))
					(p ((style "text-align:center;")) (a ((href "/"))"BACK")))))))

(defun main-handler (httpcon)
  (elnode-hostpath-dispatcher
   httpcon
   `(("^.*//name" . hello-name-handler)
     ("^.*//" . about-elnode-handler))))

(elnode-start 'main-handler :port 8010 :host "*")
;; (elnode-stop 8010)

