![murrow](http://www-tc.pbs.org/wnet/americanmasters/files/2008/09/286_murrow_intro.jpg)

Murrow
======

An Erlang implementation of the Newscast protocol.

### References

http://www.cs.unibo.it/bison/publications/ap2pc03.pdf
http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=B822FBF0D0A66BEE4FA45E2B3E2F6DF9?doi=10.1.1.97.6511&rep=rep1&type=pdf

### API

getNews()

newsUpdate(news[])

Cache Entry
Address - pid() -- dynamic
Timestamp - binary()
News Item
 - AgentID - binary() -- persistnent
 - Data - binary() (serialized term?)


$ ./bin/murrow_demo
{P1,P2,P3,P4,P5} = murrow_demo:start().
murrow:news_updatec(P1, P2, <<"news_1">>).
murrow:news_updatec(P1, P2, <<"news_2">>).
murrow:news_updatec(P1, P2, <<"news_3">>).
murrow:get_newsc(P3,P2).
