#!/bin/bash 
# LDIF DN recover
#
# Fix ldap objects with no DN attribute.
#
# FIXME: i should be use bash arrays to increase the performance. But, this is a little bit complex for me. 
# eval and awk were used for arrays operations.
#
# LICENSE: GNU GPLv3 (see LICENSE file)
#
# @author: Gerson Briglia <briglia@gmail.com>

MYNAME=$(basename $0)
###############
# Config
###############
# your ldap basedn
BASEDN="dc=UEA.EDU,dc=BR"
# the uid attribute name (openldap default is "uid")
UIDATTR="uid"
# set the new DN value (the __UID__ will be replaced by uid value)
NEWDN="$UIDATTR=__UID__,ou=Setores_Gerais,$BASEDN"

[ $# -lt 1 ] && { echo -e "\n\nUsage: $MYNAME <file.ldif>"; exit 1; }
LDIF=$1
[ ! -r "$1" ] && { echo -e "\n\nFATAL: unable to open file: $LDIF"; exit 1; }

BIFS="$IFS"
IFS="
"
i=1
for line in $(cat $LDIF); do 
    #expr="$(echo $line | sed -e s+:\ +\=\'+ -e s+\$+\'+)"
    #eval "$expr"
    unset taildn LDAP_dn PRINTDN dn uidlogin uidindex 
    # unset $(eval echo \$ATTRVAL_$i)

    [ -n "$(echo "$line" | grep "^\ ")" ] && continue;
    
    export ATTRVAL_$i="$(echo $line | cut -d' ' -f2-)";  
    export ATTRKEY_$i="$(echo $line | cut -d: -f1)";  
    [ -n "$(echo $line | grep -o "uid:")" ] && uidindex=$i;
    [ -n "$uidindex" ] && [ -z "$ATTRVAL_1" ] { ATTRVAL_1=$(echo $NEWDN | ); export ATTRVAL_1="$UIDATTR=$(eval echo \$ATTRVAL_$uidindex),$(echo $TAILDN | cut -d, -f2-)"
    if [ -n "$(echo $line | grep "^dn:" )" ]; then 
           echo | awk -v numattr=$i '{for(j=1;j<numattr;j++) { print ENVIRON["ATTRKEY_"j]": "ENVIRON["ATTRVAL_"j];}}'
           #while [ $j -le $i ]; do
           #    [ $j -eq 1 ] && ATTRVAL_1="uid=$(eval echo \$ATTRVAL_$uidindex),ou=Setores_Gerais,dc=UEA.EDU,dc=BR";
           #    echo "$(eval echo \$ATTRKEY_$j): $(eval echo \$ATTRVAL_$j)";
           #    ((j++));   
           #done; 
           i=1;
    fi
        #XXX debug 
    #echo ATTRVAL_11: $ATTRVAL_11
    #[ -z "$dn" ] && echo "############# NULL DN #############";
    #taildn="$(echo "$line" | grep -v "^dn:\|Name" | grep "BR$" | sed -e s/^\ *//)"
    #taildn="$(echo "$line" | grep "^\ .*BR$" | sed -e s/^\ *//)"
    #[ -n "$taildn" ] && { echo "Fixing broken DN ... OK - $dn$taildn"; dn="$dn$taildn"; }
    #dn="$(echo $line | grep "^dn:" | cut -d' ' -f2-)" 
    #[ -z "$dn" ] && dn="uid=__UID__,ou=Setores_Gerais,dc=UEA.EDU,dc=BR";
    #uidlogin="$(echo $line | grep "^uid:" | cut -d' ' -f2)"
    #[ -n "$uidlogin" ] && dn="$(echo "$dn" | sed -e s/__UID__/$uidlogin/)"
    #[ -n "$(echo $line | grep ^dn: )" ] && echo $dn
    #[ -z "$(echo $line | grep ^dn: )" ] && echo $line
#    echo ATTRVAL_$i = $(eval echo \$ATTRVAL_$i)
#    echo ATTRKEY_$i = $(eval echo \$ATTRKEY_$i)
    ((i++))
    #[ -n "$(echo "$line" | grep "^dn")" ] && \
    #    { 
    #        [ -z "$(echo "$line" | grep "dc.UEA" )" ] && expr=$(echo "$line" | sed -e s+\$+dc\=UEA.EDU,dc\=BR+);
    #
    #    }
   
    #echo "TAIL \"$taildn\""
        #echo "LDAP_$ATTR=$(eval 'echo "LDAP_\${ATTR}"')"
    
#    echo "$(eval $(echo $line | sed -e s+:\ +\=\'+ -e s+\\$+\'+))"; 
#    echo $uid; 
done;

IFS="$BIFS"
