How to generate "long" primary key...

**************************************************************

To easy understand probable problem lets rewrite WaitForAccess
and suppose we have one processor computer
(i.e. executing one thread at any time)

create procedure WaitForAccess
as
  declare variable Dummy integer;
begin
  while (Gen_Id(Gen_Access, 1) <> 1) do begin

    /* Delay circle */
    Dummy = Dummy * 1000;
    while (Dummy > 0) do
      Dummy = Dummy - 1;

/* This is point X */

    Dummy = Gen_Id(Gen_Access, -1);
  end
end^

I.e. we made "relatively big delay" between
Gen_Id(Gen_Access, 1) and  Gen_Id(Gen_Access, -1)
and call it  "Point X"

Let you have got 3 threads A, B, C.
They "simultaneously" enter to WaitForAccess, but A was "little" faster
then other.
"A" won and now we have following graph:

1.
A - executing the "Main block" of Gen_Id3,
B and C circling at the "point X" of WaitForAccess,
Gen_Access now equals 3

2.
A - have finished executing the "Main block" of Gen_Id3 and
executed the ReleaseAccess,
Gen_Access now equals 2
thread A finished.
B and C circling at the "point X" of WaitForAccess,

3.
B is awaken at the "point X", execute

 Dummy = Gen_Id(Gen_Access, -1);                    Gen_Access now
equals 1

 while (Gen_Id(Gen_Access, 1) <> 1) do begin     Gen_Access now equals 2

  begin executing     /* Delay circle */ and go to sleep at the "point
X"


4.
C is awaken at the "point X", execute

 Dummy = Gen_Id(Gen_Access, -1);                    Gen_Access now
equals 1

 while (Gen_Id(Gen_Access, 1) <> 1) do begin     Gen_Access now equals 2

  begin executing     /* Delay circle */ and go to sleep at the "point
X"

now we are in infinite loop 3 - 4 - 3 - 4 ...

Of course, due to nature of Server process,
sometimes we'll go away from this loop...

Unfortunately we don't have enough control over thread executing within
IB
(funny, may be fortunately :-)

So, as you have seen, there is some (very little) probability to hang
up  (to deadlock)
for indefinite period of time, but in practice you can disregard this
probability.
