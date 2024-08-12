# Generated by Django 5.0.3 on 2024-04-05 06:43

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0008_alter_appointment_barber'),
    ]

    operations = [
        migrations.AlterField(
            model_name='appointment',
            name='style_of_cut',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='appointments', to='api.styleofcut'),
        ),
    ]
