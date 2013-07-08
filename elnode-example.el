(require 'elnode)
(load-file "html-compile.el")

(defadvice elnode-http-return (around elnode-around activate)
  (if (listp (ad-get-arg 1))
      (ad-set-arg 1 (html-compile (ad-get-arg 1))))
  ad-do-it)

(ad-activate 'elnode-http-return)

(defun hello-world-handler (httpcon)
   (elnode-http-start httpcon 200 '("Content-Type" . "text/html"))
   (elnode-http-return 
       httpcon 
       '(html (body (h1 "Hello World") (p "A new day...")))))

(defun hello-name-handler (httpcon)
  (elnode-http-start httpcon 200 '("Content-Type" . "text/html"))
  (let ((a-name (elnode-http-param httpcon "name")))
    (if (eq a-name nil)
	(setq a-name "John Thomas"))
    (elnode-http-return httpcon `(html 
				  (body 
				   (h1 
				    ,(concat "Hello " a-name)))))))

(defun main-handler (httpcon)
  (elnode-hostpath-dispatcher
   httpcon
   `(("^.*//name" . hello-name-handler)
     ("^.*//" . hello-world-handler))))

(elnode-start 'main-handler :port 8010 :host "localhost")
;(elnode-stop 8010)

