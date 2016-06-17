from fabric.api import task, local, run

@task
def hello():
    local("echo 'Hello world'")

@task
def host_type():
    run("uname -a")
