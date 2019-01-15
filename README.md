# sql-history
[![Build Status](https://travis-ci.org/joaosoft/sql-history.svg?branch=master)](https://travis-ci.org/joaosoft/sql-history) | [![codecov](https://codecov.io/gh/joaosoft/sql-history/branch/master/graph/badge.svg)](https://codecov.io/gh/joaosoft/sql-history) | [![Go Report Card](https://goreportcard.com/badge/github.com/joaosoft/sql-history)](https://goreportcard.com/report/github.com/joaosoft/sql-history) | [![GoDoc](https://godoc.org/github.com/joaosoft/sql-history?status.svg)](https://godoc.org/github.com/joaosoft/sql-history)

Postgres history tables approach's

###### If i miss something or you have something interesting, please be part of this project. Let me know! My contact is at the end.

## Approach's
### 1. defining columns
###### Pros: 
* Fix the cases that we have columns with a wrong order.  
###### Cons: 
* Because having the all the fields defined in the trigger, it could happen having the history table with less fields than it should and the error would be hidden.

### 2. without defining columns
###### Pros: 
* We dont need to re-define the procedure to insert in the history table every time we add a new column.  
###### Cons: 
* Can happen that we have columns with a wrong order.

### 3. generic
###### Pros: 
* We just need to define a trigger function  
###### Cons: 
* It takes more time because we need to create the insert statement with the columns definied in the table in the correct order

## Known issues

## Follow me at
Facebook: https://www.facebook.com/joaosoft

LinkedIn: https://www.linkedin.com/in/jo%C3%A3o-ribeiro-b2775438/

##### If you have something to add, please let me know joaosoft@gmail.com
