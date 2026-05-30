source ./common.sh
checkroot




cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding repo..."

dnf install mongodb-org -y  &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "enabling and starting mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to user"

systemctl restart mongod
VALIDATE $? "restarting mongoDB"

