from fabric.api import run, task, sudo
#from cloudify import ctx


@task
def install_apache():
#    ctx.logger.info('Installing Apache httpd via fabric') # non compitable with fab utility, could be executed only via manager
#    local("ctx logger info 'installing Apache httpd...'") # could be executed only on manager
    sudo("yum -yq install httpd")
    sudo("systemctl enable httpd")
