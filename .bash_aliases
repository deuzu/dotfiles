alias l='ls -lah color=auto'
alias ..='cd ..'
alias cdw='cd /var/www/project'

alias a2rs='sudo service apache2 restart'
alias a2err='sudo tail -f /var/log/apache2/error.log'
alias a2acc='sudo tail -f /var/log/apache2/access.log'

alias ngacc='sudo tail -f /var/log/nginx/access.log'
alias ngerr='sudo tail -f /var/log/nginx/error.log'
alias ngrs='sudo service nginx restart'
alias ngt='sudo service nginx configtest'

alias sf='bin/console'
alias sf2='app/console'
alias sfcc='sf cache:clear'
alias sfdevl='tail -f var/logs/dev.log'
alias sfprodl='tail -f varlogs/prod.log'
alias sft='vendor/bin/phpunit'
