#!/bin/bash

accountMenu() {
  input() {
    read -p "Input Selection: " selectMenu
  
    if [ "$selectMenu" == "1" ]; then
      createAccount
    elif [ "$selectMenu" == "2" ]; then
      echo "List Account";
    elif [ "$selectMenu" == "" ]; then
      input
    else
      echo "Please input your selection"
      input
    fi
  }
  
  echo "1. Create new Account"
  echo "2. List Account"
  input
}

createAccount() {
  askPassword() {
    read -s -p "Password: " password
    echo
    read -s -p "Confirm Password: " confirmPassword
    echo
    
    if [ "$password" != "$confirmPassword" ]; then
      echo -n "Confirm password does not match, please try again"
      echo
      askPassword
    fi
  }
  
  echo "-----------------------"
  echo "Create New Account"
  echo "-----------------------"
  read -p "Username: " username
  read -p "Email: " email
  askPassword
  useradd 
}

accountMenu
