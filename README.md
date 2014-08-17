Homka
=====

The program is developed as a passive protection system from data theft and unauthorized access.

Program run in background of the system and do next thinks:
1. Make photo when system starts or weak up;
2. Make photo when to computer plug storage disk and unplug;
3. Gets serial key of plug disk. If serial key unknown begin collect all action with disk;
4. Do not give copy correct files on unknown disk;
5. Sends reports on email;

This project was one of the first that's why style of code can look strange.

P.S. The program has a special feature. After connecting the unknown removable disk 4 - 6 times, a disc becomes unusable, even low-level formatting does not helps. 
I commented out the functions that lead to this.
