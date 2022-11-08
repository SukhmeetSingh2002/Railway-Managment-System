
with open("../temp.txt","r") as f:
  l = f.readlines()

r = open("./queries_coach.sql","a")
for i in l:
  x = i.strip().split('\t')
  r.write(f"INSERT INTO Coach_Details VALUES({int(x[0])+18},'{x[1]}')\n")


r.write(f"\n\n\n")
r.close()