#!/bin/bash
#https://github.com/esposj/Magento-Utilities/
#Checks all nginx and httpd document roots for Magento installations.

#check for nginx
ps aux| grep nginx | grep -v grep > /dev/null
if (( $? == 0 )); then
    #get all nginx docroots
    for DOCROOT in `grep -R -i 'root ' /etc/nginx/ | grep -v DOCUMENT_ROOT | awk '{print $3}' | sed  's/;$//'`; do
	if test "$(ls -A "$DOCROOT")"; then
    	find $DOCROOT -wholename '*/app/code/core/Mage/Core/Controller/Request/Http.php' |  xargs grep -L _internallyForwarded> /dev/null
        if (( $? > 0 )); then
            echo "VULNERABLE,$DOCROOT"
        else
    	    echo "OK,$DOCROOT"
        fi
        fi
    done
fi
#check for httpd
ps aux| grep httpd | grep -v grep > /dev/null
if (( $? == 0 )); then
	for DOCROOT in `find /etc/httpd -name *.conf -exec cat {} \; | grep -v '^#' |  grep -i DocumentRoot | awk '{print $2}' | sed 's/"//g' | sort | uniq`; do
	if test "$(ls -A "$DOCROOT")"; then
 	    find $DOCROOT -wholename '*/app/code/core/Mage/Core/Controller/Request/Http.php' |  xargs grep -L _internallyForwarded> /dev/null
            if (( $? > 0 )); then
                echo "VULNERABLE,$DOCROOT"
            else
    	        echo "OK,$CUSTOMERNUMBER,$DOCROOT"
            fi
        fi
    done
fi
