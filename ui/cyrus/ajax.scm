(define-module (ui cyrus ajax)
    :use-module (alterator ajax)
    :use-module (alterator woo)
    :use-module (alterator str)
    :use-module (alterator effect)
    :export (on-load))

(define (on-load)
    (form-update-value-list
    '("virtdomains") 
	(woo-read-first "/cyrus/single" 'name "virtdomains"))
    (form-update-value-list
    '("sasl_pwcheck_method") 
	(woo-read-first "/cyrus/single" 'name "sasl_pwcheck_method"))
    (form-update-value-list (woo-read-first "/cyrus"))

    (form-bind "updt_cert" "click" cert_area)
    (form-bind "updt_sasl" "click" sasl_area)
    (form-bind "manage_sasl" "click" auxprop_area)
    (form-bind "add_sasluser" "click" add_sasluser)
    (form-bind "del_sasluser" "click" del_sasluser)
    (form-bind "set_passwd" "click" updt_saslpasswd)
    (form-bind "edit_def_sieve" "click" sieve_editor)
    (form-bind "save_def_sieve" "click" sieve_save)
    (form-bind "sasl_pwcheck_method" "change" sasl_button)
    (form-bind "sasldb_users" "change" sasl_user)
    
    (sasl_button)
)

(define (on_tls)
  (form-replace "/sslkey/generate" 'name "cyrus"))

(define (sieve_editor)
    (form-update-visibility "sieve_script" #t)
    (form-update-visibility "save_def_sieve" #t)
    (form-update-visibility "edit_def_sieve" #f)
)

(define (sieve_save)
    (catch/message
        (lambda()
        (woo-write "/cyrus/sieve_script" 
        'scriptname (form-value "autocreate_sieve_script")
        'script (form-value "sieve_script"))
        ))
    (form-update-visibility "sieve_script" #f)
    (form-update-visibility "save_def_sieve" #f)
    (form-update-visibility "edit_def_sieve" #t)
)

(define (updt_saslpasswd)
      (catch/message
        (lambda()
        (woo-write "/cyrus/saslpasswd" 
        'sasluser (form-value "sasldb_users")
        'password (form-value "saslpasswd"))
        (form-update-visibility "notifycation" #f)
        (form-update-value "saslpasswd" "")
        ))
)

(define (sasl_user . data)
    (let ((user (if (pair? data) (car data) (form-value "sasldb_users"))))
	(if (not (string-contains user ";"))
	    (begin
		(form-update-value "sel_username" user)
	)))
)

(define (add_sasluser)
    (let ((new_sasluser (form-value "new_sasluser")))
      (catch/message
        (lambda()
        (woo-new "/cyrus/sasluser" 'new_sasluser new_sasluser 'language (form-value "language"))
        (form-update-enum "sasldb_users" (woo-list "/cyrus/saslusers"))
        (form-update-value "new_sasluser" "")
        (form-update-visibility "notifycation" #t)
        )))
)

(define (del_sasluser)
    (let ((del_sasluser (form-value "sasldb_users")))
      (catch/message
        (lambda()
        (woo-delete "/cyrus/sasluser" 'del_sasluser del_sasluser 'language (form-value "language"))
        (form-update-enum "sasldb_users" (woo-list "/cyrus/saslusers"))
        (form-update-value "sel_username" "")
        )))
)


(define (sasl_button)
     (let ( (sasl_pwcheck_method (car (string-cut-repeated (or (form-value "sasl_pwcheck_method") "null") #\,))) )
      (cond
       ((string-ci=? sasl_pwcheck_method "saslauthd")(saslauthd_selected))
       ((string-ci=? sasl_pwcheck_method "auxprop")(auxprop_selected))
       (else (pwcheck_selected))))
)

(define (auxprop_selected)
    (form-update-visibility "updt_sasl" #f)
    (form-update-visibility "manage_sasl" #t)
    (form-update-visibility "sasl_area" #f)
    (form-update-visibility "pwcheck_area" #f)
    (form-update-visibility "auxprop_area" #f)
)

(define (saslauthd_selected)
    (form-update-visibility "updt_sasl" #t)
    (form-update-visibility "sasl_area" #f)
    (form-update-visibility "pwcheck_area" #f)
    (form-update-visibility "auxprop_area" #f)
    (form-update-visibility "manage_sasl" #f)
)

(define (pwcheck_selected)
       (form-update-visibility "sasl_area" #f)
       (form-update-visibility "updt_sasl" #f)
       (form-update-visibility "auxprop_area" #f)
       (form-update-visibility "manage_sasl" #f)
)

(define (sasl_area)
    (form-update-visibility "sasl_area" #t)
    (form-update-visibility "pwcheck_area" #f)
    (form-update-visibility "auxprop_area" #f)
)

(define (auxprop_area)
    (form-update-visibility "sasl_area" #f)
    (form-update-visibility "pwcheck_area" #f)
    (form-update-visibility "auxprop_area" #t)
)

(define (cert_area)
       (form-update-visibility "cert_area" #t)
)



