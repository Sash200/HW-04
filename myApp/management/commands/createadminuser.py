import os
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Creates an admin user non-interactively if it doesn't exist"
    def handle(self, *args, **options):
        User = get_user_model()

        options['username'] = 'admin'
        options['email'] = 'admin@ya.ru'
        options['password'] = 'admin'

        if not User.objects.filter(username=options['username']).exists():
            User.objects.create_superuser(username=options['username'],
                                          email=options['email'],
                                          password=options['password'])
