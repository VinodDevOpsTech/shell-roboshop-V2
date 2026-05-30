#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
USER_ID=$(id -u)

echo "$TIMESTAMP [INFO] Script started..."


checkroot(){
    if [ $USER_ID -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $R Please run with root user $N" | tee -a $LOGS_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

print_total_time(){
    echo "$TIMESTAMP [INFO] code excuted in $SECONDS seconds"
}

repo_setting(){
    cp $app_name.repo /etc/yum.repos.d/mongo.repo
    VALIDATE $? "Adding $app_name repo..."
}

app_setup(){
    
    id roboshop &>>$LOGS_FILE

    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    rm -rf /app
    VALIDATE $? "Removing existing code"

    rm -rf /tmp/catalogue.zip
    VALIDATE $? "Removed catalogue zip"

    mkdir -p /app  &>>$LOGS_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
    cd /app 
    unzip /tmp/catalogue.zip &>>$LOGS_FILE
    VALIDATE $? "Downloaded and extracted catalogue code"
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    dnf module enable nodejs:20 -y  &>>$LOGS_FILE
    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing NodeJS:20"
    
    npm install  &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Created systemctl service"
    systemctl daemon-reload
    systemctl enable $app_name &>>$LOGS_FILE
    VALIDATE $? "enabling $?app_name"
}



app_restart(){
    systemctl restart $app_name &>>$LOGS_FILE
    VALIDATE $? "Restarting $app_name"
}

java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Building package"

    mv target/*.jar shipping.jar &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}