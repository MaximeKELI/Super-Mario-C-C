#include "Player.h"
#include <algorithm>

const float Player::GRAVITY = 800.0f;
const float Player::JUMP_FORCE = -400.0f;
const float Player::MOVE_SPEED = 200.0f;
const float Player::MAX_FALL_SPEED = 500.0f;
const float Player::SHOOT_COOLDOWN = 0.5f;

Player::Player(float x, float y) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 32.0f;
    mRect.h = 32.0f;
    mBaseHeight = 32.0f;
    mVelocityX = 0.0f;
    mVelocityY = 0.0f;
    mOnGround = false;
    mDead = false;
    mIsBig = false;
    mHasFirePower = false;
    mShootCooldown = 0.0f;
}

void Player::Update(float deltaTime) {
    if (mDead) return;
    
    // Appliquer la gravité
    if (!mOnGround) {
        mVelocityY += GRAVITY * deltaTime;
        mVelocityY = std::min(mVelocityY, MAX_FALL_SPEED);
    }
    
    // Mettre à jour la position
    mRect.x += mVelocityX * deltaTime;
    mRect.y += mVelocityY * deltaTime;
    
    // Limiter la position horizontale
    if (mRect.x < 0) {
        mRect.x = 0;
        mVelocityX = 0;
    }
    
    // Appliquer la friction horizontale
    mVelocityX *= 0.9f;
}

void Player::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Couleur selon le power-up
    if (mHasFirePower) {
        // Mario avec pouvoir de feu - rouge et blanc
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Chapeau blanc
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect hat = {renderRect.x, renderRect.y, renderRect.w, 8};
        SDL_RenderFillRectF(renderer, &hat);
    } else if (mIsBig) {
        // Mario grand - rouge
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
    } else {
        // Mario petit - rouge
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
    }
    
    // Dessiner les yeux
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    float eyeSize = mIsBig ? 6.0f : 4.0f;
    float eyeY = mIsBig ? renderRect.y + 10 : renderRect.y + 8;
    SDL_FRect eye1 = {renderRect.x + 8, eyeY, eyeSize, eyeSize};
    SDL_FRect eye2 = {renderRect.x + (mIsBig ? 22 : 20), eyeY, eyeSize, eyeSize};
    SDL_RenderFillRectF(renderer, &eye1);
    SDL_RenderFillRectF(renderer, &eye2);
}

void Player::HandleInput(const Uint8* keystate) {
    if (mDead) return;
    
    // Mouvement horizontal
    if (keystate[SDL_SCANCODE_LEFT] || keystate[SDL_SCANCODE_A]) {
        mVelocityX = -MOVE_SPEED;
    } else if (keystate[SDL_SCANCODE_RIGHT] || keystate[SDL_SCANCODE_D]) {
        mVelocityX = MOVE_SPEED;
    }
    
    // Saut
    if ((keystate[SDL_SCANCODE_SPACE] || keystate[SDL_SCANCODE_UP] || keystate[SDL_SCANCODE_W]) && mOnGround) {
        mVelocityY = JUMP_FORCE;
        mOnGround = false;
    }
}

void Player::SetPosition(float x, float y) {
    mRect.x = x;
    mRect.y = y;
}

void Player::SetVelocity(float vx, float vy) {
    mVelocityX = vx;
    mVelocityY = vy;
}

void Player::Respawn(float x, float y) {
    SetPosition(x, y);
    SetVelocity(0, 0);
    mDead = false;
    mOnGround = false;
    // Garder les power-ups après respawn (optionnel - on peut les réinitialiser)
    // mIsBig = false;
    // mHasFirePower = false;
}

void Player::CollectMushroom() {
    if (!mIsBig) {
        mIsBig = true;
        mRect.h = mBaseHeight * 1.5f;
        mRect.y -= mBaseHeight * 0.5f; // Ajuster la position
    }
}

void Player::CollectFireFlower() {
    mHasFirePower = true;
    if (!mIsBig) {
        CollectMushroom(); // La fleur de feu grandit aussi Mario
    }
}

void Player::Shrink() {
    if (mIsBig) {
        mIsBig = false;
        mHasFirePower = false;
        mRect.h = mBaseHeight;
        mRect.y += mBaseHeight * 0.5f; // Ajuster la position
    }
}

void Player::Shoot() {
    if (CanShoot()) {
        mShootCooldown = SHOOT_COOLDOWN;
        // La logique de création de la boule de feu sera dans Game
    }
}

void Player::UpdateShootCooldown(float deltaTime) {
    if (mShootCooldown > 0) {
        mShootCooldown -= deltaTime;
    }
}

