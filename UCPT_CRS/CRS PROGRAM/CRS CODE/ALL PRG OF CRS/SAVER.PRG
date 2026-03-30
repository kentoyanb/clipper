scroll()
asaver := savescreen(00,00,24,79)
setcursor(.f.)


** display u **

        for ncol := 1 to 80
                @ 08,ncol say "ллллл   ллллл" color "gr+/n"
                @ 09,ncol say " ллл     ллл " color "gr+/n"
                @ 10,ncol say " ллл     ллл " color "gr+/n"
                @ 11,ncol say " ллл     ллл " color "gr+/n"
                @ 12,ncol say " ллл     ллл " color "gr+/n"
                @ 13,ncol say " ллл     ллл " color "gr+/n"
                @ 14,ncol say " лллл   лллл " color "gr+/n"
                @ 15,ncol say " плллллллллп " color "gr+/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
        next


        for ncol := 80 to 1 step -1
                @ 08,ncol say "ллллл   ллллл                                       " color "gr+/n"
                @ 09,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 10,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 11,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 12,ncol say " ллл     ллл                                        " color "gr+/n"
                @ 13,ncol say " ллл     ллл лпл л л л лп лпм лпп л плп л л   лпл лп" color "gr+/n"
                @ 14,ncol say " лллл   лллл л л л л л лп лмп ппл л  л   л    л л лп" color "gr+/n"
                @ 15,ncol say " плллллллллп л л л плп лм л л ммл л  л   л    лмл л " color "gr+/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol-1,15,ncol+80,asaver)
        next

** end of letter u **


** display letter c **

        for ncol := 1 to 80
                @ 08,ncol say "млллллллллм" color "bg+/n"
                @ 09,ncol say "ллл      лл" color "bg+/n"
                @ 10,ncol say "ллл        " color "bg+/n"
                @ 11,ncol say "ллл        " color "bg+/n"
                @ 12,ncol say "ллл        " color "bg+/n"
                @ 13,ncol say "ллл        " color "bg+/n"
                @ 14,ncol say "ллл      лл" color "bg+/n"
                @ 15,ncol say "плллллллллп" color "bg+/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
        next

        for ncol := 80 to 1 step -1
                @ 08,ncol say "млллллллллм           " color "bg+/n"
                @ 09,ncol say "ллл      лл           " color "bg+/n"
                @ 10,ncol say "ллл                   " color "bg+/n"
                @ 11,ncol say "ллл                   " color "bg+/n"
                @ 12,ncol say "ллл                   " color "bg+/n"
                @ 13,ncol say "ллл         лп лпм л л" color "bg+/n"
                @ 14,ncol say "ллл      лл лп лпм л л" color "bg+/n"
                @ 15,ncol say "плллллллллп лм лмп лмл" color "bg+/n"

                for nctr := 1 to 5000
                next

                restscreen(08,ncol-1,15,ncol+80,asaver)
        next


** end of letter c **


** display letter m **

        for ncol := 1 to 80
                @ 08,ncol say "лллллл    лллллл" color "r+/n"
                @ 09,ncol say " лллллн  оллллл " color "r+/n"
                @ 10,ncol say " лллпллноллпллл " color "r+/n"
                @ 11,ncol say " ллл  пллп  ллл " color "r+/n"
                @ 12,ncol say " ллл        ллл " color "r+/n"
                @ 13,ncol say " ллл        ллл " color "r+/n"
                @ 14,ncol say " ллл        ллл " color "r+/n"
                @ 15,ncol say "ллллл      ллллл" color "r+/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
        next

** end of letter m **

** begin letter e **

        for ncol := 1 to 80
                @ 08,ncol say "ллллллллллл" color "b/n"
                @ 09,ncol say " ллл      п" color "b/n"
                @ 10,ncol say " ллл       " color "b/n"
                @ 11,ncol say " ллллллл   " color "b/n"
                @ 12,ncol say " ллл       " color "b/n"
                @ 13,ncol say " ллл       " color "b/n"
                @ 14,ncol say " ллл      м" color "b/n"
                @ 15,ncol say "ллллллллллл" color "b/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
        next

** end of letter e **

** begin letter t **

        for ncol := 1 to 80
                @ 08,ncol say "ллллллллллллл" color "g/n"
                @ 09,ncol say "п    ллл    п" color "g/n"
                @ 10,ncol say "     ллл     " color "g/n"
                @ 11,ncol say "     ллл     " color "g/n"
                @ 12,ncol say "     ллл     " color "g/n"
                @ 13,ncol say "     ллл     " color "g/n"
                @ 14,ncol say "     ллл     " color "g/n"
                @ 15,ncol say "    ллллл    " color "g/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
        next

** end of letter t **


** begin letter c **

        for ncol := 1 to 80
                @ 08,ncol say "лллллллллллл" color "rb/n"
                @ 09,ncol say " ллл      лл" color "rb/n"
                @ 10,ncol say " ллл        " color "rb/n"
                @ 11,ncol say " ллл        " color "rb/n"
                @ 12,ncol say " ллл        " color "rb/n"
                @ 13,ncol say " ллл        " color "rb/n"
                @ 14,ncol say " ллл      лл" color "rb/n"
                @ 15,ncol say "лллллллллллл" color "rb/n"

                for nctr := 1 to 10000
                next

                restscreen(08,ncol,15,ncol,asaver)
        next
** end of letter c **
wait


