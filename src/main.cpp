/*
  main.cpp
  main application file for raylib based object oriented programming example

  developer     tiny@solidice.com
  date          aug 19, 2026
*/
#include "raylib.h"
#include <vector>
#include <stdint.h>
#include <algorithm>

uint64_t  __now = 0 ;
uint32_t  __screen_cx = 1280 ;
uint32_t  __screen_cy = 1024 ;

uint64_t timeGetTime()
{
    return GetTime() * 1000; // Convert seconds to milliseconds
} // :: timeGetTime

class Shape
{
    protected:
      static uint32_t  __id ; // static id counter
      uint32_t  _id ; // unique id for each shape
      uint64_t  _expire_ts ; // expiration timestamp in milliseconds
      int16_t   _x ;
      int16_t   _y ;
      int16_t   _width ;
      int16_t   _height ;
      Color     _color ;

      Vector2   _dir ;
      Vector2   _velocity ;

    public :
    Shape() { 
        _id = __id++; // assign unique id
        randomize() ;
    }
    virtual ~Shape() {}

    virtual void Draw() = 0;
    virtual void randomize() { 
        _expire_ts = __now + rand() % 9000 + 1000; // random expiration between 1 and 10 seconds
        _x = rand() % (__screen_cx - _width);
        _y = rand() % (__screen_cy - _height);
        _width = rand() % 100 + 20; // random width between 20 and 120
        _height = rand() % 100 + 20; // random height between 20 and 120
        _color = Color{(unsigned char)(rand() % 256), (unsigned char)(rand() % 256), (unsigned char)(rand() % 256), 255};

        // movement
        _dir.x = (rand() % 20) + 5; // -1, 0, or 1
        _dir.y = (rand() % 20) + 5; // -1, 0, or 1
        _velocity.x = (float)(rand() % 20 + 5); // random speed between 1 and 5
        _velocity.y = (float)(rand() % 20 + 5); // random speed between 1 and 5
    } 
    virtual void twitch( uint32_t dt ) {
        // Update position based on direction and velocity
        // if the shape hits the screen boundaries, reverse direction
        _x += (int)((double)(_dir.x * _velocity.x * dt) / 1000.0);
        _y += (int)((double)(_dir.y * _velocity.y * dt) / 1000.0);
        if (_x < 0) { _x = 0; _dir.x *= -1; }
        if (_y < 0) { _y = 0; _dir.y *= -1; }
        if (_x + _width > __screen_cx) { _x = __screen_cx - _width; _dir.x *= -1; }
        if (_y + _height > __screen_cy) { _y = __screen_cy - _height; _dir.y *= -1; }
    }
    virtual bool isExpired() { return __now >= _expire_ts; }

    uint32_t id() const { return _id; }
}; // class Shape

uint32_t Shape::__id = 0; 

class Box : public Shape
{
    public:
    Box() : Shape() {}
    Box(int x, int y, int width, int height, Color color)
    : Shape()
    {
        _x = x;
        _y = y;
        _width = width;
        _height = height;
        _color = color;
    }

    void Draw() override
    {
        DrawRectangle(_x, _y, _width, _height, _color);
    }
}; // class Box

class Square : public Box
{
    public:
    Square() : Box() {}
    Square(int x, int y, int size, Color color)
        : Box(x, y, size, size, color) {}
}; // class Square

class Ellipse : public Shape
{
    public:
    Ellipse() : Shape() {}
    Ellipse(int x, int y, int radiusX, int radiusY, Color color)
    : Shape() {
        _x = x;
        _y = y;
        _width = radiusX * 2;
        _height = radiusY * 2;
        _color = color; 
    }

    void Draw() override
    {
        DrawEllipse(_x, _y, _width / 2, _height / 2, _color);
    }
}; // class Ellipse

class Circle : public Ellipse
{
    public:
    Circle() : Ellipse() {}
    Circle(int x, int y, int radius, Color color)
        : Ellipse(x, y, radius, radius, color) {}
}; // class Circle

void bring_out_yer_dead( std::vector<Shape*>& shapes )
{
    for (auto it = shapes.begin(); it != shapes.end(); )
    {
        if ((*it)->isExpired())
        {
            delete *it; // Free the memory
            it = shapes.erase(it); // Remove from vector and get new iterator
            if (it == shapes.end()) break; // Check if we reached the end
        }
        else
        {
            ++it; // Move to next shape
        }
    }
} // :: bring_out_yer_dead

Shape *factory( int type )
{
    Shape *shape = nullptr;
    switch (type)
    {
        case 0: shape = new Box(); break;
        case 1: shape = new Square(); break;
        case 2: shape = new Ellipse(); break;
        case 3: shape = new Circle(); break;
        default: shape = nullptr; break;
    }
    if (shape) {
        shape->randomize(); // Randomize the shape's properties
    }
    return shape;
} // :: factory

void draw_shapes( std::vector<Shape*>& shapes )
{
    for (auto shape : shapes)
        if (!shape->isExpired())
            shape->Draw();
} // :: draw_shapes

void spawn( std::vector<Shape*>& shapes, int count )
{
    for (int i = 0; i < count; ++i)
    {
        int type = rand() % 4; // Randomly choose a shape type
        Shape *shape = factory(type);
        if (shape) {
            shapes.push_back(shape);
        }
    }
} // :: spawn

void draw_frame()
{
    DrawLine(1, 0, __screen_cx, 0, SKYBLUE);
    DrawLine(1, 0, 0, __screen_cy, SKYBLUE);
    DrawLine(__screen_cx - 1, 0, __screen_cx - 1, __screen_cy, SKYBLUE);
    DrawLine(1, __screen_cy - 1, __screen_cx, __screen_cy - 1, SKYBLUE);
} // :: draw_frame

int main( int argc, const char *argv[] )
{
    InitWindow(__screen_cx, __screen_cy, "raylib [core] example - basic window");
    SetTargetFPS(60);

    std::vector<Shape*> shapes;
    uint32_t last_time = 0 ;
    uint32_t dt = 0 ;

    while (!WindowShouldClose())
    {
        __now = timeGetTime();
        dt = __now - last_time;
        if ((dt == 0) || (dt > 1000)) continue ;
        last_time = __now;

        for (auto shape : shapes)  shape->twitch(dt);

        bring_out_yer_dead(shapes);

        if (shapes.size() < 10) spawn(shapes, 5); 

        BeginDrawing();
          ClearBackground(BLACK);
          draw_shapes(shapes);
          DrawText("Hello, raylib!", 190, 200, 20, LIGHTGRAY);
          draw_frame();
        EndDrawing();
    }

    CloseWindow();

    return 0 ;
} // :: main


