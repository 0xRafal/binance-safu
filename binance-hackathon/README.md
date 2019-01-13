# Binance Hackathon

This is the backend of Binance Hackathon.

## git remote for pushing to demo server
Make sure you have set your public key for the deploy-bot account
```
git remote add demo deploy-bot@ec2-18-216-165-179.us-east-2.compute.amazonaws.com:/var/repo/binance-hackathon.git
```
Then, you can use the following to push code to demo server
```
git push demo master
```

## Clone all related projects from git

```bash
npm run setup
```


## Pull all related projects

```bash
npm run git-pull
```

## Push update of shell scripts to all related projects

```bash
npm run update-projects
npm run git-push
```

## Commit message

Please update the following message, and
```bash
Commit: update README.md
```
run the following command
```bash
npm run commit
```
