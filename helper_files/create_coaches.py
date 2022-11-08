
with open("./temp.txt","r") as f:
  l = f.readlines()

r = open("../queries_coach.sql","a")
for i in l:
  x = i.strip().split(' ')
  r.write(f"INSERT INTO sl_coach VALUES({x[0]},'{x[1]}')\n")


r.write(f"\n\n\n")
r.close()