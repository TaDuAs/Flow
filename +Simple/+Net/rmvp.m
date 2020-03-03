function str=rmvp(str)
while(str(end)==' ' || str(end)==newline || str(end) == sprintf('\r')), str=str(1:end-1); end