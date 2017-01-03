import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioOutput out;

AudioPlayer rain1;
AudioPlayer rain2;
AudioPlayer rain3;
AudioPlayer rain4;

PImage pic;
int count = 0;

//size of box being analysed
int boxWidth=200;
int boxHeight = 100;

//size of webcam image
int imageWidth = 352;
int imageHeight =228;

int rowIndex = 144*352;
int pixelIndex =0;

int cycleRate =40;

void setup()
{
   minim = new Minim(this); 
  
   size(352,228); //size
      
   //***Test Image***
   //pic = loadImage("images.jpg");
   
   //***Play in daylight***
   pic = loadImage("http://www.trafficnz.info/camera/70.jpg?68b06d2d1de5f034198cf765e0f4cb60");
   
   pic.loadPixels();
   image(pic, 0, 0);
  
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  //loading files
  rain1 = minim.loadFile("drop1.mp3");
  rain2 = minim.loadFile("drop2.mp3");
  rain3 = minim.loadFile("drop3.mp3");
  rain4 = minim.loadFile("drop4.mp3");
}

void draw()
{ 
  // load sounds into an array to be accessed randomly
  AudioPlayer[] sounds = {rain1,rain2,rain3,rain4};
   
   if (count == 0)
  {
     pixelIndex = rowIndex;
  }// if this is the first call of draw then make the pixIndex the first element in the box
     
   if (count%boxWidth == 0)
  {
     rowIndex += imageWidth*2; // move 2 rows down at a time to speed up analyzing image
     pixelIndex = rowIndex;
  }      
  int soundIndex = int(random(sounds.length)); //randomly pick sounds from array audioplayer
  
  color pixelColor = pic.pixels[pixelIndex];// consider color of pixel at pixel index
  
  background(pixelColor);
  
  pixelColor = pixelColor & 0x00FFFFFF; //makes hex value positive
   
   //representing the amount of colour in each pixel by seperating them out
   
  int pixelRed = pixelColor & 0x00FF0000;
   pixelRed = pixelRed >> 16; //right shift by 16 bits to consider red component
   pixelRed = pixelRed+20; //Differenciate tones between colours so red tones higher and blue tones lower
   
   
  int pixelGreen = pixelColor & 0x0000FF00;
   pixelGreen = pixelGreen >> 8;
   pixelGreen = pixelGreen+0;
   
  int pixelBlue = pixelColor & 0x000000FF;
   pixelBlue = pixelBlue >> 0;
   pixelBlue = pixelBlue-20;

  int pixelAverage = (pixelBlue + pixelRed + pixelGreen)/3; // taking average of 3 colour values
/*
  println(pixelAverage);
  println("red"+pixelRed);
  println("green"+pixelGreen);
  println("blue"+pixelBlue);
 */
  if (pixelAverage > 170 && pixelRed > 170 && pixelGreen < 200 && pixelBlue < 200 ) //playing sound only when one colour is significantly higher than the others to signify a prominant colour
  {
    frameRate(1); //slowing down frame rate to allow sound to play in full
    (sounds[soundIndex]).play();
    (sounds[soundIndex]).rewind();
  }
 else if (pixelAverage > 170 && pixelRed < 200 && pixelGreen > 170 && pixelBlue < 200 )
  { 
    frameRate(1);
    (sounds[soundIndex]).play();
    (sounds[soundIndex]).rewind();
  }
  else if (pixelAverage > 180 && pixelRed < 200 && pixelGreen < 200 && pixelBlue > 170 ) 
  {
    frameRate(1);
    (sounds[soundIndex]).play();
    (sounds[soundIndex]).rewind();
  }
  else 
  { 
    frameRate(cycleRate);
    out.playNote(0.0, 0.9,pixelAverage); //playing average of colours in pixel which directly link to audio frequency 
  }
  //***Older workings***
  /*
  //looking for cars in the red/orange coloured range
  if(pixelColor > 0xFFFF0000 && pixelColor < 0xFFFFFF55)
   {
     frameRate(1);
     (sounds[soundIndex]).play();
    (sounds[soundIndex]).rewind();
   }
   //look for greens
  else if(pixelColor > 0xFF004400 && pixelColor < 0xFF00FF66)
   {
     frameRate(1);
     (sounds[soundIndex]).play();
    (sounds[soundIndex]).rewind();
   }
  //look for blues 
  else if(pixelColor > 0xFF000077 && pixelColor < 0xFF0088FF)
   {
     frameRate(1);
     (sounds[soundIndex]).play();
    (sounds[soundIndex]).rewind(); 
   }
   */
  //***Older workings***
  
  pixelIndex++; //looking pixel in box
  count += 3; // looking at every 3rd pixel assuming either side is roughly the same colour
   
  if(pixelIndex == imageWidth*227){ // end of y-axis in image so reset row index
  rowIndex =  imageWidth*(imageHeight -boxHeight); //resetting to 1st index of the box being analyzed 
  count = 0;
  }
} 
//Closing minim 
void stop()
{

  out.close();
  rain1.close();
  rain2.close();
  rain3.close();
  rain4.close();
 
  minim.stop(); 
  super.stop();
}
//look at box being analysed
//look at colour calibration

