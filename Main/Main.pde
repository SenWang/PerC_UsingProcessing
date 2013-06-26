import intel.pcsdk.*;

short[] depthMap;
short[] irMap;

int[] depth_size = new int[2];
int[] ir_size = new int[2];
int[] rgb_size = new int[2];
  
PImage rgbImage, depthImage, irImage;
PXCUPipeline session;

void setup()
{
  size(960, 240);
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.COLOR_VGA|PXCUPipeline.DEPTH_QVGA))
    exit();

  //SETUP RGB IMAGE 
  if(session.QueryRGBSize(rgb_size))
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);

  //SETUP DEPTH MAP
  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }

  //SETUP IR IMAGE
  if(session.QueryIRMapSize(ir_size))
  {
    irMap = new short[ir_size[0] * ir_size[1]];
    irImage=createImage(ir_size[0], ir_size[1], ALPHA);
  }
}

void draw()
{ 
  background(0);

  if (session.AcquireFrame(false))
  {
    session.QueryRGB(rgbImage);
    
    float remapMouseX = map(mouseX, 0, width, 255, 8192);
    float remapMouseY = map(mouseY, 0, height, 255, 8192);

    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    session.QueryDepthMap(depthMap);
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
    {
      depthImage.pixels[i] = color(map(depthMap[i], 0, remapMouseX, 0, 255));
    }
    depthImage.updatePixels();

    //REMAPPING THE IR IMAGE TO A PIMAGE
    session.QueryIRMap(irMap);
    for (int i = 0; i < ir_size[0]*ir_size[1]; i++) {
      irImage.pixels[i] = color(map(irMap[i], 0, remapMouseY, 0, 255));
    }
    irImage.updatePixels();
    session.ReleaseFrame();//VERY IMPORTANT TO RELEASE THE FRAME
  }
  
  image(rgbImage, 0, 0, 320, 240);
  image(depthImage, 320, 0, 320, 240);
  image(irImage, 640, 0, 320, 240);
}


void exit()
{
  session.Close(); 
  super.exit();
}
