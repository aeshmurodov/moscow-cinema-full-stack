import pytest
from django.urls import reverse
from tickets_api.models import Ticket


# 1) Попытка создать билет без авторизации → 401
@pytest.mark.django_db
def test_ticket_create_unauthorized(client):
    """
    Неавторизованный запрос к /api/tickets/ должен вернуть 401.
    Тестирует TicketViewSet + JWTAuthentication.
    """
    url = reverse("ticket-list")  # /api/tickets/

    response = client.post(url, {
        "ticket_number": "A1",
        "movie_title": "Avatar",
        "start_time": "2025-01-01T10:00:00Z",
        "seat_number": "B5",
    })

    assert response.status_code == 401


# 2) Создание билета с авторизованным пользователем → 201
@pytest.mark.django_db
def test_ticket_create_authorized(client, django_user_model):
    """
    Авторизованный пользователь с валидным JWT может создать билет.
    Тестирует:
      - получение токена по /api/users/token/ (token_obtain),
      - создание билета по /api/tickets/ (ticket-list),
      - привязку билета к текущему пользователю.
    """
    user = django_user_model.objects.create_user(
        username="user1",
        password="pass12345"
    )

    # 1. Получаем JWT access-токен
    token_url = reverse("token_obtain")
    token_response = client.post(token_url, {
        "username": "user1",
        "password": "pass12345",
    })
    assert token_response.status_code == 200
    access = token_response.json()["access"]

    # 2. Добавляем заголовок авторизации
    client.defaults["HTTP_AUTHORIZATION"] = f"Bearer {access}"

    # 3. Создаём билет
    url = reverse("ticket-list")

    response = client.post(url, {
        "ticket_number": "A1",
        "movie_title": "Avatar",
        "start_time": "2025-01-01T10:00:00Z",
        "seat_number": "B5",
    })

    assert response.status_code == 201

    # 4. Проверяем, что билет реально создан и привязан к нашему пользователю
    ticket = Ticket.objects.get(ticket_number="A1")
    assert ticket.user == user

