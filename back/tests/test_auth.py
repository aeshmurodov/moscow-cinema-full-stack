import pytest
from django.urls import reverse


@pytest.mark.django_db
def test_login_success(client, django_user_model):
    """
    Успешный логин: получаем JWT access/refresh токены.
    Тестирует эндпоинт /api/users/token/ (name='token_obtain').
    """
    django_user_model.objects.create_user(
        username="testuser",
        password="StrongPass123!"
    )

    # URL: /api/users/token/
    url = reverse("token_obtain")

    response = client.post(url, {
        "username": "testuser",
        "password": "StrongPass123!"
    })

    assert response.status_code == 200
    data = response.json()
    assert "access" in data
    assert "refresh" in data


@pytest.mark.django_db
def test_login_fail_wrong_password(client, django_user_model):
    """
    Неверный пароль: SimpleJWT должен вернуть 401 Unauthorized.
    """
    django_user_model.objects.create_user(
        username="testuser",
        password="StrongPass123!"
    )

    url = reverse("token_obtain")

    response = client.post(url, {
        "username": "testuser",
        "password": "wrong"
    })

    assert response.status_code == 401
