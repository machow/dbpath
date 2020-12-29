# dbpath

<!-- badges: start -->
[![R build status](https://github.com/machow/dbpath/workflows/R-CMD-check/badge.svg)](https://github.com/machow/dbpath/actions)
<!-- badges: end -->

dbpath is an R library for creating database connections via a single string (url).

## Examples

```R
library(dbpath)

sql_url <- dbpath("postgresql+RPostgres://some_user:some_password@localhost:5432")
sql_url
```

```
[1] "postgresql+RPostgres://some_user:****@localhost:5432"
```

You can use the `dbpath` output with either DBI::dbConnect, or dplyr::tbl to create a remote connection.

```R
# get a database connection
con <- DBI::dbConnect(sql_url)

# get a database table called mtcars
tbl_mtcars <- dplyr::tbl(sql_url, "mtcars")
tbl_mtcars
```

## URL Format

`dbpath` URLs follow the format below.

```
<dialect>+<driver>://<username>:<password>@<host>:<port>/<database>
```

Here's an example using mysql:

```R
mysql_url <- "mysql+RMariaDB://root:some_password@localhost"
```

In this case, we're connecting to the mysql dialect, using R's MariaDB package as a driver.

The code below shows how it translates to making the connection manually.

```R
# dbpath
DBI::dbConnect(mysql_url)

# manual
DBI::dbConnect(
  RMariaDB::MariaDB(),
  user = "root",
  password = "some_password",
  host = "localhost"
  )
```

Behind the scenes, `dbpath` uses driver hooks to know that if RMariaDB is the driver, then we need its MariaDB() object.
Note that the `RMariaDB` in `mysql+RMariaDB` is optional!

## Configuring Driver Hooks

The code below adds a custom driver for SQLite.

```R
library(dbpath)

driver_registry$set(my_driver = function () RSQLite::SQLite)

# Note the 3 slashes, rather than two, meaning no user name, password, or host
sqlite_url <- "sqlite+my_driver:///:memory:"

sqlite_url
```

```
[1] "sqlite+my_driver://:****@/:memory:"
```

```R
DBI::dbConnect(sqlite_url)
```

```
<SQLiteConnection>
  Path: :memory:
  Extensions: TRUE
```

### Available Driver Hooks


```R
# see available drivers
driver_registry$get()

# see defaults for when no driver is specified
driver_defaults$get()
```

Here are the current driver defaults:

```
 postgresql       mysql     mariadb 
"RPostgres"  "RMariaDB"  "RMariaDB" 
```

## Interoperability with Python

`dbpath's` approach is based on python's SQLAlchemy library.
This means that you can use the same string across languages!

```R
sql_url = "postgresql://user:password@localhost:port/dbname"
```

<table width="100%">
  <thead>
    <tr>
      <th>R</th>
      <th>python</th>
    </tr>
  </thead>
  <tr>
    <!-- r example -->
    <td><pre><code>library(dbpath)
DBI::dbconnection(sql_url)
</code></pre>
    </td>
    <!-- python example -->
    <td><pre><code>import sqlalchemy
sqlalchemy.create_engine(sql_url)
</code></pre>
    </td>
  </tr>
</table>

