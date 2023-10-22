from django.db import models

# Create your models here.

class MyModel(models.Model):
   id = models.AutoField(primary_key=True)
   phone = models.CharField(max_length=20)

   def __str__(self):
      return self.phone