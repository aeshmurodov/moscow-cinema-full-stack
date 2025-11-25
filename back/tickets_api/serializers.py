from rest_framework import serializers
from .models import Ticket

class TicketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ticket
        fields = ['id','ticket_number','movie_title','start_time','seat_number']
    
    def validate_price(self, value):
        if value < 500:
            raise serializers.ValidationError("Минимальная сумма покупки — 500 рублей")
        return value