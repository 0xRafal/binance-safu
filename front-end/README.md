# Git push to demo
run the following command for adding repository for demon (make sure you have added your public certificate to deploy-bot)
```
git remote add demo deploy-bot@ec2-18-216-165-179.us-east-2.compute.amazonaws.com:/var/repo/front-end.git
```
Then you can use the following command to commit
```
git push demo master
```
# The demostration site:
http://ec2-18-216-165-179.us-east-2.compute.amazonaws.com/report.html
http://ec2-18-216-165-179.us-east-2.compute.amazonaws.com/comment.html
