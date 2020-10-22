OPTIONS="rcms"
while getopts $OPTIONS opt; do
    echo "opciones => ${opt}"
    case "${opt}" in
    r)
        echo "la opcion -r"
        rake RAILS_ENV=development db:drop db:create db:migrate db:seed
        ;;
    c)
        echo "la opcion -c"
        rails c
        ;;
    m)
        echo "la opcion -m"

        rake db:migrate 
        # rake db:migrate RAILS_ENV=production
        ;;
    s)
        echo "la opcion -s"
        rails s -b 0.0.0.0
        ;;
    p)
        echo "la opcion -p"
        rails s -b 0.0.0.0 -e production
        ;;
    *)
        exit 2
        ;;
    esac
done
