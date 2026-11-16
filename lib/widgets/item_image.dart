import 'package:flutter/material.dart';
import '../models/item_model.dart';import '../utils/app_colors.dart';
class ItemImage extends StatelessWidget{
 final ItemModel item;final double? width,height;final BoxFit fit;
 const ItemImage({super.key,required this.item,this.width,this.height,this.fit=BoxFit.cover});
 String get _fallback{
 final t=(item.itemName+' '+item.category).toLowerCase();
 if(t.contains('laptop')||t.contains('notebook'))return 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=900';
 if(t.contains('mikroskop')||t.contains('optik'))return 'https://images.unsplash.com/photo-1581093458791-9d42e3c5e3b4?w=900';
 if(t.contains('arduino')||t.contains('breadboard')||t.contains('komponen')||t.contains('elektronik'))return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=900';
 if(t.contains('proyektor')||t.contains('projector')||t.contains('audio visual'))return 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=900';
 if(t.contains('router')||t.contains('jaringan'))return 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=900';
 if(t.contains('multimeter')||t.contains('ukur'))return 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900';
 return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=900';
 }
 @override Widget build(BuildContext context){final url=item.image.trim();return SizedBox(width:width,height:height,child:url.isEmpty?_load(_fallback,true):_load(url,false));}
 Widget _load(String url,bool fallback){return Image.network(url,fit:fit,width:width,height:height,errorBuilder:(context,error,stack){if(!fallback)return _load(_fallback,true);return _placeholder();},loadingBuilder:(context,child,progress)=>progress==null?child:Container(width:width,height:height,color:AppColors.background,alignment:Alignment.center,child:const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2))));}
 Widget _placeholder(){final t=(item.itemName+' '+item.category).toLowerCase();final icon=t.contains('laptop')?Icons.laptop_mac:t.contains('mikroskop')?Icons.biotech:t.contains('ukur')?Icons.straighten:t.contains('jaringan')?Icons.router:t.contains('proyektor')?Icons.videocam:t.contains('arduino')||t.contains('komponen')?Icons.memory:Icons.devices_other;return Container(width:width,height:height,color:AppColors.background,alignment:Alignment.center,child:Icon(icon,color:AppColors.primary,size:38));}
}
