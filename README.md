# sql-history
[![Build Status](https://travis-ci.org/joaosoft/sql-history.svg?branch=master)](https://travis-ci.org/joaosoft/sql-history) | [![codecov](https://codecov.io/gh/joaosoft/sql-history/branch/master/graph/badge.svg)](https://codecov.io/gh/joaosoft/sql-history) | [![Go Report Card](https://goreportcard.com/badge/github.com/joaosoft/sql-history)](https://goreportcard.com/report/github.com/joaosoft/sql-history) | [![GoDoc](https://godoc.org/github.com/joaosoft/sql-history?status.svg)](https://godoc.org/github.com/joaosoft/sql-history)

Postgres history tables approach's

###### If i miss something or you have something interesting, please be part of this project. Let me know! My contact is at the end.

## Approach's
### 0. without-history
###### Benchmark: 
````
goos: darwin
goarch: amd64
pkg: sql-history/0.without-history
Benchmark-4   	       1	23379745112 ns/op
PASS
ok  	sql-history/0.without-history	23.398s
````

### 1. defining columns
###### Pros: 
* Fix the cases that we have columns with a wrong order.  
###### Cons: 
* Because having the all the fields defined in the trigger, it could happen having the history table with less fields than it should and the error would be hidden.
###### Benchmark: 
````
goos: darwin
goarch: amd64
pkg: sql-history/1.defining-columns
Benchmark-4   	       1	29561407891 ns/op
PASS
ok  	sql-history/1.defining-columns	29.583s
````

### 2. without defining columns
###### Pros: 
* We dont need to re-define the procedure to insert in the history table every time we add a new column.  
###### Cons: 
* Can happen that we have columns with a wrong order.
###### Benchmark: 
````
goos: darwin
goarch: amd64
pkg: sql-history/2.without-defining-columns
Benchmark-4   	       1	28070046002 ns/op
PASS
ok  	sql-history/2.without-defining-columns	28.093s
````

### 3. generic
###### Pros: 
* We just need to define a trigger function  
###### Cons: 
* It takes more time because we need to create the insert statement with the columns definied in the table in the correct order
###### Benchmark: 
````
goos: darwin
goarch: amd64
pkg: sql-history/3.generic
Benchmark-4   	       1	90137351091 ns/op
PASS
ok  	sql-history/3.generic	90.161s
````

### 4. generic with improvements
###### Pros: 
* We just need to define a trigger function  
###### Cons: 
* It takes more time because we need to create the insert statement with the columns definied in the table in the correct order
###### Benchmark: 
````
goos: darwin
goarch: amd64
pkg: sql-history/4.generic-with-improvement
Benchmark-4   	       1	36915125535 ns/op
PASS
ok  	sql-history/4.generic-with-improvement	36.936s
````

### 5. generic with improvement with joins
###### Pros: 
* We just need to define a trigger function  
###### Cons: 
* It takes more time because we need to create the insert statement with the columns defined in the table in the correct order
###### Benchmark: 
````
2019/01/23 11:24:17 connecting database with driver [ postgres ] and data source [ postgres://postgres:postgres@localhost:7100/foursource?sslmode=disable ]
goos: darwin
goarch: amd64
pkg: sql-history/5.tests
Benchmark-4   	       1	59692435669 ns/op
PASS
ok  	sql-history/5.tests	59.708s
````

## Known issues

## Follow me at
Facebook: https://www.facebook.com/joaosoft

LinkedIn: https://www.linkedin.com/in/jo%C3%A3o-ribeiro-b2775438/

##### If you have something to add, please let me know joaosoft@gmail.com
