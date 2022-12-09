# dbpath print hides passwords

    Code
      dbpath("a+b://c:my_password@d")
    Output
      <dbpath>
      a+b://c:****@d

# dbpath url-decodes and encodes passwords

    Code
      print(dbpath(url_pwd), hide_password = FALSE)
    Output
      <dbpath>
      drv://user:p%40ssw%2Ard@host

# dbpath url-decodes and encodes query parameters

    Code
      print(dbpath(url_q))
    Output
      <dbpath>
      drv://user@host/db?foo=bar%20and%20baz

