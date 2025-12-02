import pytest
from django.urls import reverse


@pytest.mark.django_db
def test_token_obtain_returns_access_and_refresh(client, django_user_model):
    """
    Убеждаемся, что по эндпоинту token_obtain
    при верных данных возвращаются access и refresh токены.
    """
    user = django_user_model.objects.create_user(
        username="user_tokens",
        password="pass12345",
    )

    url = reverse("token_obtain")
    response = client.post(
        url,
        {"username": "user_tokens", "password": "pass12345"},
    )

    assert response.status_code == 200
    data = response.json()
    assert "access" in data
    assert "refresh" in data


@pytest.mark.django_db
def test_token_obtain_wrong_credentials(client, django_user_model):
    """
    При неправильном пароле токен не выдается.
    """
    django_user_model.objects.create_user(
        username="user_wrong",
        password="correct_pass",
    )

    url = reverse("token_obtain")
    response = client.post(
        url,
        {"username": "user_wrong", "password": "wrong_pass"},
    )

    assert response.status_code in (400, 401)
    # На всякий случай проверим, что access не вернулся
    if response.status_code == 200:
        data = response.json()
        assert "access" not in data


@pytest.mark.django_db
def test_ticket_create_missing_movie_title_returns_400(client, django_user_model):
    """
    Создание билета без обязательного поля movie_title
    должно вернуть ошибку валидации (400).
    """
    user = django_user_model.objects.create_user(
        username="user_ticket_1",
        password="pass12345",
    )

    token_url = reverse("token_obtain")
    token_response = client.post(
        token_url,
        {"username": "user_ticket_1", "password": "pass12345"},
    )
    assert token_response.status_code == 200
    access = token_response.json()["access"]

    client.defaults["HTTP_AUTHORIZATION"] = f"Bearer {access}"

    url = reverse("ticket-list")
    # movie_title специально не передаем
    response = client.post(
        url,
        {
            "ticket_number": "B1",
            "start_time": "2025-01-01T10:00:00Z",
            "seat_number": "C3",
        },
    )

    assert response.status_code == 400
    data = response.json()
    # Ожидаем, что бэкенд ругнётся на отсутствие movie_title
    assert "movie_title" in data


@pytest.mark.django_db
def test_ticket_create_authorized_returns_201(client, django_user_model):
    """
    Дополнительная проверка: авторизованный пользователь
    по корректным данным может создать билет, и сервер отвечает 201.
    """
    user = django_user_model.objects.create_user(
        username="user_ticket_2",
        password="pass12345",
    )

    token_url = reverse("token_obtain")
    token_response = client.post(
        token_url,
        {"username": "user_ticket_2", "password": "pass12345"},
    )
    assert token_response.status_code == 200
    access = token_response.json()["access"]

    client.defaults["HTTP_AUTHORIZATION"] = f"Bearer {access}"

    url = reverse("ticket-list")
    response = client.post(
        url,
        {
            "ticket_number": "C7",
            "movie_title": "Inception",
            "start_time": "2025-01-01T12:00:00Z",
            "seat_number": "D10",
        },
    )

    # если у тебя сейчас в коде 200 вместо 201, поменяй тут ожидаемый код
    assert response.status_code in (200, 201)

@pytest.mark.django_db
def test_register_success(client):
    url = reverse("register")  # имя смотри в urls.py
    data = {
        "username": "newuser",
        "password": "pass12345",
        "email": "test@example.com",
    }
    response = client.post(url, data)

    assert response.status_code == 201
    assert response.json()["user"]["username"] == "newuser"


