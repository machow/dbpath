# dbpath print hides passwords

    Code
      dbpath("a+b://c:my_password@d")
    Output
      <dbpath>
      a+b://c:****@d

# dbpath url-decodes and encodes usernname and password

    Code
      print(dbpath(url_user_pass), hide_password = FALSE)
    Output
      <dbpath>
      drv://%24%40lly:p%40ssw%2Ard@host

# dbpath url-decodes and encodes query parameters

    Code
      print(dbpath(url_q))
    Output
      <dbpath>
      drv://user@host/db?foo=bar%20and%20baz

