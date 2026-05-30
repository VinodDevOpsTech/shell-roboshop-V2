source ./common.sh
checkroot

dnf module disable redis -y &>>$LOGS_FILE
dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? " disabling and enabling redis"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections to user"

systemctl enable redis &>> $LOGS_FILE
systemctl start redis &>> $LOGS_FILE
VALIDATE $? "Started Redis"

print_total_time