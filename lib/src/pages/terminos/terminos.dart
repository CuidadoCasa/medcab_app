import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';


class ViewTerminosPage extends StatefulWidget {
  
  final int tipo;
  const ViewTerminosPage({
    super.key,
    required this.tipo
  });

  @override
  State<ViewTerminosPage> createState() => _ViewTerminosPageState();
}

class _ViewTerminosPageState extends State<ViewTerminosPage> {
  
  // late PdfController _pdfController;
  String titulo = '';
  String pathDocumento = '';
  
  @override
  void initState() {
    _initData();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _pdfController.dispose();
  //   super.dispose();
  // }

  void _initData(){

    if(widget.tipo == 0){
      titulo = 'Términos y Condiciones';
      pathDocumento = 'terminos_condiciones';
    }
    if(widget.tipo == 1){
      titulo = 'Aviso de Privacidad';
      pathDocumento = 'aviso_privacidad';
    }

    // _pdfController = PdfController(
    //   document: PdfDocument.openAsset('assets/pdf/$pathDocumento.pdf'),
    // );

    setState((){});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaColors().fondoMain,
      appBar: AppBar(
        backgroundColor: PaletaColors().fondoMain,
        elevation: 1,
        title: Text(
          titulo,
          style: const TextStyle(
            fontFamily: 'Titulos',
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
      ),
      // bottomNavigationBar: _iconsPages(),
      body: PdfViewer.openAsset(
        'assets/docs/$pathDocumento.pdf'
        // scrollDirection: Axis.vertical,
        // pageSnapping: false,
        // builders: PdfViewBuilders<DefaultBuilderOptions>(
        //   options: const DefaultBuilderOptions(),
        //   documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        //   pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        //   pageBuilder: _pageBuilder,
        // ),
        // controller: _pdfController,
      ),
    );
  }

  // Widget _iconsPages(){
    
  //   final ancho = MediaQuery.of(context).size.width;

  //   return SizedBox(
  //     width: ancho,
  //     height: 80,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           IconButton(
  //             icon: const Icon(Icons.navigate_before),
  //             onPressed: () {
  //               _pdfController.previousPage(
  //                 curve: Curves.ease,
  //                 duration: const Duration(milliseconds: 100),
  //               );
  //             },
  //           ),
  //           PdfPageNumber(
  //             controller: _pdfController,
  //             builder: (_, loadingState, page, pagesCount) => Container(
  //               alignment: Alignment.center,
  //               child: Text(
  //                 '$page/${pagesCount ?? 0}',
  //                 style: const TextStyle(fontSize: 22),
  //               ),
  //             ),
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.navigate_next),
  //             onPressed: () {
  //               _pdfController.nextPage(
  //                 curve: Curves.ease,
  //                 duration: const Duration(milliseconds: 100),
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // PhotoViewGalleryPageOptions _pageBuilder(
  //   BuildContext context,
  //   Future<PdfPageImage> pageImage,
  //   int index,
  //   PdfDocument document,
  // ) {
  //   return PhotoViewGalleryPageOptions(
  //     basePosition: Alignment.topCenter,
  //     imageProvider: PdfPageImageProvider(
  //       pageImage,
  //       index,
  //       document.id,
  //     ),
  //     minScale: PhotoViewComputedScale.contained * 1,
  //     maxScale: PhotoViewComputedScale.contained * 2,
  //     initialScale: PhotoViewComputedScale.covered * 1.0,
  //     heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
  //   );
  // }
}