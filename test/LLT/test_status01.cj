// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

main (){
    let statu = StatusLine()
    let str = StatusLine.HTTP_TEMP_REDIRECT
    let str1 = StatusLine.HTTP_PERM_REDIRECT
    let str2 = StatusLine.HTTP_MULT_CHOICE
    let str3 = StatusLine.HTTP_MOVED_PERM
    let str4 = StatusLine.HTTP_MOVED_TEMP
    let str5 = StatusLine.HTTP_SEE_OTHER
    return 0
}

