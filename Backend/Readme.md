## Backend configuration

The `app.py` file is a Flask web application that provides an API endpoint for handling POST requests related to project data. 

***All the instructions here should be followed in this directory only.***

# Setup Instruction

1) Install Python and nginx on your server using the package manager of the Operating system using.
For Ubuntu Server
```bash
sudo apt install -y nginx python3 python3-venv python3-flask
```

For RHEL Server
```bash
sudo yum install -y nginx python3 python3-venv python3-flask
```

For Fedora Server
```bash
sudo dnf install -y nginx python3 python3-venv python3-flask
```

2) Start the nginx server with the following command
```bash
sudo systemctl enable nginx --now
```

3) Make 2 directories in /etc/nginx dir if they are not present in /etc/nginx
```bash
sudo mkdir /etc/nginx/sites-available /etc/nginx/sites-enabled
```

4) Replace the <SERVER_IP_ADDRESS> with the server's IP-address in post.conf and then copy the post.conf in /etc/nginx/sites-available and create a Symbolic link between /etc/nginx/sites-available/post.conf and /etc/nginx/sites-enabled and restart the nginx service.
```bash
sudo cp post.conf /etc/nginx/sites-available
```

```bash
sudo ln -s /etc/nginx/sites-available/post.conf /etc/nginx/sites-enabled/
```

```bash
sudo systemctl restart nginx
```
5) Check if there is any error in the nginx configuration using the following command.
```bash
sudo nginx -t
```

If you see the follwoing output then the confugration is ok.Else check the configuration file.
```bash
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

*The next 3(6,7,8) steps are Optional steps. To run app.py we need flask and we have installed flask in the first command.If you want you can skip this 3 steps.*

6) Create a virtual enviroment for python using the following command and also activate the venv.
```python
python -m venv venv
```
```bash
source venv/bin/activate
```

7) Install the required python packages for the python file.
```python
pip install -r requirement.txt
```
If the following command doesnot work then use the following command.
```bash
./venv/bin/pip install -r requirement.txt
```

8) Start the python file.This will run the app in foreground
```python
python app.py
```
TO run it in background use the following command.
```python
nohup python3 app.py &>/dev/null &
```

The Python app is started
