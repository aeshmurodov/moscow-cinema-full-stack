import pytest
from django.urls import reverse

# 1) Попытка создать билет без авторизации → 401
@pytest.mark.django_db
def test_ticket_create_unauthorized(client):
    url = reverse("ticket-list")  # /tickets/

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
    user = django_user_model.objects.create_user(
        username="user1",
        password="pass12345"
    )

    client.force_login(user)

    url = reverse("ticket-list")

    response = client.post(url, {
        "ticket_number": "A1",
        "movie_title": "Avatar",
        "start_time": "2025-01-01T10:00:00Z",
        "seat_number": "B5",
    })

    assert response.status_code == 201
    assert response.json()["user"] == user.id
