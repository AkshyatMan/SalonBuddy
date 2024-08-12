# Generated by Django 5.0.3 on 2024-04-15 11:35

import django.core.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0017_alter_appointment_style_of_cut'),
    ]

    operations = [
        migrations.AlterField(
            model_name='appointment',
            name='rating',
            field=models.DecimalField(blank=True, decimal_places=2, max_digits=5, null=True, validators=[django.core.validators.MinValueValidator(0), django.core.validators.MaxValueValidator(5)]),
        ),
    ]
