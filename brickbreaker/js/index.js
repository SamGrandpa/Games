const rulesBtn = document.getElementById('rules-btn');
const closeBtn = document.getElementById('close-btn');
const rules = document.getElementById('rules');
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');

// Ball stats
const ball_startX = canvas.width/2;
const ball_startY = canvas.height - 30;
const ball_size = 10;
const ball_speed = 3;
const ball_dx = 2;
const ball_dy = -3;
const ball_color = '#199FE0';

// Paddle stats
const paddle_startX = canvas.width/2 - 40;
const paddle_startY = canvas.height - 20;
const paddle_width = 80;
const paddle_height = 10;
const paddle_speed = 8;
const paddle_dx = 0;
const paddle_color = '#199FE0';

// Bricks stats
const brickRowCount = 9;
const brickColumnCount = 5;
const brick_width = 70;
const brick_height = 20;
const bricks_spacing = 10;
const distance_left = 45;
const distance_top = 60;
const brick_color = '#199FE0';

// Score stats
const score_font = '20px Arial';
const score_offsetX = canvas.width/2-30;
const score_offsetY = 30;

const is_visible = true;

let isGameOver = false;

class Ball {
    constructor(x, y, size, speed, dx, dy) {
        this.x = x;
        this.y = y;
        this.size = size;
        this.speed = speed;
        this.dx = Math.random() < 0.5 ? dx : -dx;
        this.dy = dy;
    }

    drawBall() {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fillStyle = ball_color;
        ctx.fill();
        ctx.closePath();
    }

    reset() {
        this.x = ball_startX;
        this.y = ball_startY; 
        this.dx = ball_dx;
        this.dy = ball_dy; 
    }
    
    moveBall() {
        this.x += this.dx;
        this.y += this.dy;
    }

    stop() {
        this.dx = 0;
        this.dy = 0;
    }

    testWallCollision() {
        // left and right wall
        if (this.x - this.size < 0 || this.x + this.size > canvas.width) {
            this.dx *= -1;
        }
        
        // top wall
        if (this.y - this.size < 0) {
            this.dy *= -1;
        }

        // Hit bottom wall - GameOver
        if (this.y + this.size > canvas.height) {
            gameOver();
        }
    }

    testPaddleCollision(paddle) {
        // Ball collision against the paddle
        if (this.x - this.size > paddle.x &&
            this.x + this.size < paddle.x + paddle.w &&
            this.y + this.size > paddle.y) {
            this.dy = -1*ball_speed;
        }
    }
}

class Paddle {
    constructor(x, y, w, h, speed, dx) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.speed = speed;
        this.dx = dx;
    }

    drawPaddle() {
        ctx.beginPath();
        ctx.rect(this.x, this.y, this.w, this.h);
        ctx.fillStyle = paddle_color;
        ctx.fill();
        ctx.closePath();
    }

    reset() {
        this.x = paddle_startX;
        this.y = paddle_startY;
    }
  
    moveLeft() {
        this.dx = -this.speed;
    }
  
    moveRight() {
        this.dx = this.speed;
    }
  
    stop() {
        this.dx = 0;
    }
  
    movePaddle() {
        this.x += this.dx;
    }

    paddleControl() {
        document.addEventListener('keydown', event => {
            switch (event.keyCode) {
                case 37: // left arrow key pressed
                    this.moveLeft();
                    break;
                case 39: // right arrow key pressed
                    this.moveRight();
                    break;
            }
        });
        document.addEventListener('keyup', event => {
            switch (event.keyCode) {
                case 37: // left arrow key released
                    this.stop();
                case 39: // right arrow key released
                    this.stop();
            }
        });
    }

    testCollision() {  
        // Test paddle collision against the left wall
        if (this.x + this.w > canvas.width) {
            this.x = canvas.width - this.w;
        }
        
        // Test paddle collision against the right wall
        if (this.x < 0) {
            this.x = 0;
        }
    }
  }

class Bricks {
    constructor(brickInfo) {
        this.brickInfo = brickInfo;

        //initialize all bricks
        this.bricks = [];
        for (let i = 0; i < brickRowCount; i++) {
            this.bricks[i] = [];
            for (let j = 0; j < brickColumnCount; j++) {
                const x = i * (this.brickInfo.w + this.brickInfo.padding) + this.brickInfo.offsetX;
                const y = j * (this.brickInfo.h + this.brickInfo.padding) + this.brickInfo.offsetY;
                this.bricks[i][j] = { x, y, ...this.brickInfo };
            }
        }
    }

    drawBricks() {
        this.bricks.forEach(column => {
            column.forEach(brick => {
                ctx.beginPath();
                ctx.rect(brick.x, brick.y, brick.w, brick.h);
                ctx.fillStyle = brick.visible ? brick_color : 'transparent';
                ctx.fill();
                ctx.closePath();
            });
        });

    }
    
    testCollision(ball, score) {
        this.bricks.forEach(column => {
            column.forEach(brick => {
                if (brick.visible) {
                    if (ball.x - ball.size > brick.x &&           // Check brick left side 
                        ball.x + ball.size < brick.x + brick.w && // Check brick right side check
                        ball.y + ball.size > brick.y &&           // Check brick top
                        ball.y - ball.size < brick.y + brick.h    // Check brick bottom
                        ) {
                        ball.dy *= -1;
                        brick.visible = false;
            
                        score.increaseScore();
                    }
                }
            });
        });
    }

    // Visualize all bricks
    showAllBricks() {
        this.bricks.forEach(column => {
            column.forEach(brick => (
                brick.visible = true
            ));
        });
    }
}

class Score {
    constructor() {
        let initialScore = 0;
        this.score = initialScore;
        this.font = score_font;
        this.offsetX = score_offsetX;
        this.offsetY = score_offsetY;
    }

    drawScore() {
        ctx.font = this.font;
        ctx.fillText(`Score: ${this.score}`, this.offsetX, this.offsetY);
    }

    reset() {
        this.score = 0;
    }

    increaseScore() {
        this.score++;

        // All bricks are gone, game over
        if (this.score % (brickRowCount * brickColumnCount) === 0) {
            gameOver();
        }
    }
}

class Game{
    constructor() {
        let ball = new Ball(ball_startX, ball_startY, ball_size, ball_speed, ball_dx, ball_dy);
        let paddle = new Paddle(paddle_startX, paddle_startY, paddle_width, paddle_height, paddle_speed, paddle_dx);
        let bricks = new Bricks({w: brick_width, h: brick_height, padding: bricks_spacing,
                                offsetX: distance_left, offsetY: distance_top, visible: is_visible});
        let score = new Score();
        
        this.ball = ball;
        this.paddle = paddle;
        this.bricks = bricks;
        this.score = score;

    }

    draw() {
        //Clear canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        this.ball.drawBall();
        this.paddle.drawPaddle();
        this.score.drawScore();
        this.bricks.drawBricks();

        this.showMessage();
    }
    
    showMessage() {
        let winMsg = 'Congrats. You Won !';
        let loseMsg = 'Game Over. You Lost !';

        ctx.font = '50px Arial';
        if (isGameOver) {
            if (this.score.score >= (brickRowCount * brickColumnCount)) {
                ctx.fillText(winMsg, 150, canvas.height/2);
             }
             else{
                ctx.fillText(loseMsg, 150, canvas.height/2);
    
            }
            
            ctx.fillText('Press Space bar to restart.', 120, canvas.height/2 + 100);
        }
    }


    btnControl() {
        // Rules and close event handlers
        rulesBtn.addEventListener('click', () => rules.classList.add('show'));
        closeBtn.addEventListener('click', () => rules.classList.remove('show'));
    }

    restart() {
        isGameOver = false;        
    }

    testIfGameOver() {
        if (isGameOver) {
            this.ball.stop();
            this.paddle.stop();
            document.addEventListener('keydown', event => {
            switch (event.keyCode) {
                case 32: // Space bar pressed to restart the game
                    this.restart();
                    this.bricks.showAllBricks();
                    this.score.reset();
                    this.paddle.reset();
                    this.ball.reset();
                    
                    break;
            }
        });
        } else {
            this.ball.moveBall();
            this.ball.testWallCollision();
            this.ball.testPaddleCollision(this.paddle);
    
            this.paddle.movePaddle();
            this.paddle.paddleControl();
            this.paddle.testCollision();
    
            this.bricks.testCollision(this.ball, this.score);
        }
    }
    
    run() {
        this.testIfGameOver();
        this.draw();
        this.btnControl();
        
        requestAnimationFrame(this.run.bind(this));
    }
}

function gameOver() {
    isGameOver = true;
}

// Create a game object and run the game
let newGame = new Game();
newGame.run();


