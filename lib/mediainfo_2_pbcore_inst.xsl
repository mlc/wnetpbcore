<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mt="http://www.iana.org/assignments/media-types/" xmlns:la="http://www.loc.gov/standards/iso639-2/" xmlns:str="http://exslt.org/strings" extension-element-prefixes="str" xmlns="http://www.pbcore.org/PBCore/PBCoreNamespace.html" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<xsl:output encoding="UTF-8" method="xml" version="1.0" indent="yes"/>

<!--

Title: mediainfo_2_pbcore_inst.xsl
Version: 0.0.9
Based on Mediainfo version 0.7.27
Based on PBCore version 1.2.1

	© tbd
	Created by David Rice to transform XML output of MediaInfo (http://mediainfo.sourceforge.net by MediaArea, SARL) to an instantiation element of a PBCore 1.2.1 record (http://www.pbcore.org). The translation expects that MediaInfo be operated with the '-f', '__Language=Raw', and '__Output=XML' options (change double-underscores to double-hyphens). The translation is customized for mediainfo version 0.7.27 and may provide unexpected results with other versions of mediainfo.
		
	Updated for use with the Secure Media Network of the Dance Heritage Coaliation, September 2009.

	This work employs PBCore. The PBCore (Public Broadcasting Metadata Dictionary) was created by the public broadcasting community in the United States of America for use by public broadcasters and others. Initial development funding for PBCore was provided by the Corporation for Public Broadcasting. The PBCore is built on the foundation of the Dublin Core (ISO 15836), an international standard for resource discovery (http://dublincore.org), and has been reviewed by the Dublin Core Metadata Initiative Usage Board. Copyright: 2005, Corporation for Public Broadcasting. 
		
		
		Example use:
		
		a. generate mediainfo.xml (change double-underscore to double-hyphen)
		
		   mediainfo -f __Language=raw __Output=XML file.mov > mediainfo.xml
		
		b. use mediainfo_2_pbcore_inst.xsl to transform mediainfo.xml to pbcore.xml
		
		   xsltproc mediainfo_2_pbcore_inst.xsl mediainfo.xml > pbcore.xml
		   
		Or as one line:
		
		   mediainfo __Language=raw -f __Output=XML file.mov > mediainfo.xml && xsltproc mediainfo_2_pbcore_inst.xsl mediainfo.xml > pbcore.xml
		   
		Notes:
		
		- aspect ratio shows in human readable form (4/3) if available, else in decimal (1.42)
		- perhaps use "Audio/Channel_s_" to help determine track config
		- formatTracks and formatChannelConfiguration need some serious work
		- strategy for formatDigital???
		- overall I prefer to use integer expressions when it makes sense, thus this document will state formatSamplingRate="44100" instead of "44.1 kHz"
		- the expression of dates needs standardization
		   
-->

	<!-- if you use the PBCore 'version' attribute, you can set it globally here, else to set individually for elements change the xsl:use-attribute-sets attributes where they are used -->
	<xsl:attribute-set name="pbcore1.2.1">
		<xsl:attribute name="version">PBCoreXSD_Ver_1.2_D1</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:key name="lang-lookup" match="la:lang" use="@one"/>
	<xsl:variable name="langs-top" select="document('')/*/la:langs"/>
	
	<xsl:template match="Mediainfo">
		<xsl:for-each select="File">
			<pbcoreInstantiation>
			
				<xsl:for-each select="track[@type='General']">

					<xsl:if test="FileName">
						<pbcoreFormatID>
							<formatIdentifier><xsl:value-of select="FileName"/></formatIdentifier>
							<formatIdentifierSource xsl:use-attribute-sets="pbcore1.2.1">File Name</formatIdentifierSource>
						</pbcoreFormatID>
					</xsl:if>
					
					<xsl:for-each select="str:tokenize(OriginalSourceMedium, '/')"><!-- this matches on the 'uuid' element in Final Cut XML Interchange Format-->
						<pbcoreFormatID>
							<formatIdentifier><xsl:value-of select="normalize-space(.)"/></formatIdentifier>
							<formatIdentifierSource xsl:use-attribute-sets="pbcore1.2.1">Original Source Medium</formatIdentifierSource>
						</pbcoreFormatID>
					</xsl:for-each>
					
					<xsl:for-each select="str:tokenize(Media_UUID, '/')"><!-- this matches on the 'uuid' element in Final Cut XML Interchange Format-->
						<pbcoreFormatID>
							<formatIdentifier><xsl:value-of select="normalize-space(.)"/></formatIdentifier>
							<formatIdentifierSource xsl:use-attribute-sets="pbcore1.2.1">Final Cut Studio UUID</formatIdentifierSource>
						</pbcoreFormatID>
					</xsl:for-each>
					
					<xsl:for-each select="str:tokenize(Media_History_UUID, '/')"><!-- this matches on the 'uuid' element in Final Cut XML Interchange Format-->
						<pbcoreFormatID>
							<formatIdentifier><xsl:value-of select="normalize-space(.)"/></formatIdentifier>
							<formatIdentifierSource xsl:use-attribute-sets="pbcore1.2.1">Final Cut Studio UUID Item History</formatIdentifierSource>
						</pbcoreFormatID>
					</xsl:for-each>

					
					<xsl:choose><!-- this give preference to the date the file was encoded, else use the date of the recording if noted. Needs date standardization. -->
						<xsl:when test="Encoded_Date">
							<dateCreated>
								<xsl:choose>
									<xsl:when test="substring(Encoded_Date,1,3)='UTC' and string-length(Encoded_Date)='23'">
										<xsl:value-of select="substring(Encoded_Date,5,10)"/><xsl:text>T</xsl:text><xsl:value-of select="substring(Encoded_Date,16,8)"/><xsl:text>Z</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="Encoded_Date"/>
									</xsl:otherwise>
								</xsl:choose>
							</dateCreated>
						</xsl:when>
						
						<xsl:when test="Recorded_Date">
							<dateCreated>
								<xsl:choose>
									<xsl:when test="substring(Recorded_Date,1,3)='UTC' and string-length(Recorded_Date)='23'">
										<xsl:value-of select="substring(Recorded_Date,5,10)"/><xsl:text>T</xsl:text><xsl:value-of select="substring(Encoded_Date,16,8)"/><xsl:text>Z</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="Recorded_Date"/>
									</xsl:otherwise>
								</xsl:choose>
							</dateCreated>
						</xsl:when>
						
					</xsl:choose>
					
					<!-- UTC 2009-12-05 20:30:57 -->
					
					<!-- dateIssued: not computer:identifiable, right? -->
					<!-- <dateIssued/> -->
					
					<!-- formatPhysical: is this applicable in a mapping from a digital file analysis? -->
					<!-- <formatPhysical xsl:use-attribute-sets="pbcore1.2.1"></formatPhysical> -->
					
					<!-- formatDigital: this is mandatory if applicable, and certainly applicable. Currently MediaInfo does not report on mime type. Potentially generate a mime type in another external XML doc and then use the document() function to call it. -->
					<!-- <formatDigital xsl:use-attribute-sets="pbcore1.2.1"></formatDigital> -->
					
					<xsl:if test="InternetMediaType">
						<formatDigital>
							<xsl:value-of select="InternetMediaType"/>
						</formatDigital>
					</xsl:if>
					
					<formatLocation><xsl:value-of select="CompleteName"/></formatLocation><!-- filepath -->
					
					<xsl:choose><!-- attempts to make a guess at formatMediaType. There is no method to clarify if a file is 'Animation' vs 'Moving Image', 'Presentation' vs 'Text', etc. Only these four possible mediaTypes are tested. More tests could be added here later to make better guesses. -->
						<xsl:when test="VideoCount > 0"><formatMediaType xsl:use-attribute-sets="pbcore1.2.1">Moving Image</formatMediaType></xsl:when>
						<xsl:when test="AudioCount > 0"><formatMediaType xsl:use-attribute-sets="pbcore1.2.1">Sound</formatMediaType></xsl:when>
						<xsl:when test="ImageCount > 0"><formatMediaType xsl:use-attribute-sets="pbcore1.2.1">Static Image</formatMediaType></xsl:when>
						<xsl:when test="TextCount  > 0"><formatMediaType xsl:use-attribute-sets="pbcore1.2.1">Text</formatMediaType></xsl:when>
					</xsl:choose>
					
					<formatGenerations xsl:use-attribute-sets="pbcore1.2.1"></formatGenerations><!-- currently I don't make any assumptions here -->
					
					<xsl:if test="FileSize"><!-- this expresses filesize as an integer count of bytes, switch to 'FileSize/String' for human-readable rounded value with unit of measurement -->
						<formatFileSize><xsl:value-of select="FileSize"/></formatFileSize>
					</xsl:if>
					
					<xsl:choose>
						<xsl:when test="Delay_Original_String3"><formatTimeStart><xsl:value-of select="Delay_Original_String3"/></formatTimeStart></xsl:when>
						<xsl:when test="Delay_String3"><formatTimeStart><xsl:value-of select="Delay_String3"/></formatTimeStart></xsl:when>
					</xsl:choose>
					
					<xsl:if test="Duration_String3"><!-- prefer duration as HH:MM:SS.mmmm, use 'Duration_String' for human-readable with unit of measurement -->
						<formatDuration><xsl:value-of select="Duration_String3"/></formatDuration>
					</xsl:if>
					
					<xsl:if test="OverallBitRate"><!-- prefer to express bitrate as an integer count of bytes per second, switch to 'OverallBitRate/String' for human-readable rounded value with unit of measurement -->
						<formatDataRate><xsl:value-of select="OverallBitRate"/></formatDataRate>
					</xsl:if>
					
					<!-- yeah I know, this field is about color as displayed not color as stored, potentially a slow mplayer test could determine if color is used. Although formatColors is at the instantiation level, this digs into Mediainfo's video track to find the color data, not sure how to handle video with multiple video tracks of various colors. 
					
					update: Colorimetry was moved to the essenceTrackAnnotation of the relevant essenceTrack
					
					<xsl:if test="../track[@type='Video']/Colorimetry">
					    <formatColors xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="../track[@type='Video']/Colorimetry"/></formatColors>
				    </xsl:if>
				    
				    -->
					
					<!-- this method is broken and disabled. It attempts to replicate the human readable samples provided on pbcore.org, but doesn't work right. Could this be switched to a integer of track count? is this needed when there are essenceTracks? replaced with count below.
					<formatTracks>
						<xsl:if test="VideoCount"><xsl:value-of select="VideoCount"/> video,</xsl:if>
						<xsl:if test="AudioCount"> <xsl:value-of select="AudioCount"/> audio,</xsl:if>
						<xsl:if test="AudioCount"> <xsl:value-of select="TextCount"/> text,</xsl:if>
						<xsl:if test="AudioCount"> <xsl:value-of select="ChaptersCount"/> chapters,</xsl:if>
						<xsl:if test="AudioCount"> <xsl:value-of select="ImageCount"/> image,</xsl:if>
						<xsl:if test="MenuCount"> <xsl:value-of select="MenuCount"/> menu,</xsl:if>
					</formatTracks>
					-->
					
					<!-- formatTracks: simply an integer of tracks that Mediainfo reports (this is not the same as what Quicktime reports) -->
					<formatTracks>
						<xsl:value-of select="count(../track[@type!='General'])"/>
					</formatTracks>
					
					<!-- this is disabled and is likely not helpful to anyone, possibly could be refined if I can make a custom channel configuration statement once per track group per track then concatenate them here
					<formatChannelConfiguration>
						<xsl:if test="Video_Format_WithHint_List"><xsl:value-of select="Video_Format_WithHint_List"/> + </xsl:if>
						<xsl:if test="Audio_Format_WithHint_List"><xsl:value-of select="Audio_Format_WithHint_List"/> + </xsl:if>
						<xsl:if test="Text_Format_WithHint_List"><xsl:value-of select="Text_Format_WithHint_List"/> + </xsl:if>
						<xsl:if test="Chapters_Format_WithHint_List"><xsl:value-of select="Chapters_Format_WithHint_List"/> + </xsl:if>
						<xsl:if test="Image_Format_WithHint_List"><xsl:value-of select="Image_Format_WithHint_List"/> + </xsl:if>
						<xsl:if test="Menu_Format_WithHint_List"><xsl:value-of select="Menu_Format_WithHint_List"/> + </xsl:if>
					</formatChannelConfiguration>
					-->
					
					<!-- language is currently disabled until I have a reliable method to meet pbcore's language validation requirements. This requires a ISO639-1 to ISO639-2 lookup table
					<language xsl:use-attribute-sets="pbcore1.2.1"></language>
					-->
					
					<xsl:if test="Language">
						<language>
							<xsl:apply-templates select="$langs-top">
								<xsl:with-param name="curr-language" select="Language"/>
							</xsl:apply-templates>
						</language>
					</xsl:if>
					
					<!-- nothing here yet, some of this could be inferred by essenceTracks of type 'Text', 'Chapters' or 'Menu' -->
					<!-- <alternativeModes></alternativeModes> -->
					
				</xsl:for-each>
				
				<xsl:for-each select="track[@type!='General']">
				  <pbcoreEssenceTrack>
				  
					<xsl:choose><!-- some translation of reported trackType, else reported as is -->
						<xsl:when test="Format='TimeCode'"><essenceTrackType>timecode</essenceTrackType></xsl:when>
						<xsl:when test="Format='EIA-608'"><essenceTrackType>caption</essenceTrackType></xsl:when>
						<xsl:when test="Format='EIA-708'"><essenceTrackType>caption</essenceTrackType></xsl:when>
						<xsl:otherwise><essenceTrackType><xsl:value-of select="@type"/></essenceTrackType></xsl:otherwise>
					</xsl:choose>
					
				    <xsl:choose><!-- essenceTrackIdenfier may only occur once, although it is not required it seems to be generally best practice to have one, although with some file types this concept doesn't really exist. This method prefers to take the report track ID else just uses a counter for that trackType (which means it could repeat within the same instantiation. ... -->
				    	<xsl:when test="ID">
						    <essenceTrackIdentifier><xsl:value-of select="ID"/></essenceTrackIdentifier>
						    <essenceTrackIdentifierSource>ID (Mediainfo)</essenceTrackIdentifierSource>
					    </xsl:when>
				    	<xsl:when test="StreamKindID">
						    <essenceTrackIdentifier><xsl:value-of select="StreamKindID"/></essenceTrackIdentifier>
						    <essenceTrackIdentifierSource>StreamKindID (Mediainfo)</essenceTrackIdentifierSource>
				   		</xsl:when>
				   	</xsl:choose>
				    
				    <xsl:if test="Standard">
				    	<essenceTrackStandard xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="Standard"/></essenceTrackStandard>
				    </xsl:if>
				    
				    <xsl:if test="Format"><!-- not sure how best to handle encoding, feel free to remove the extra xsl:if statements to reduce verbosity -->
					    <essenceTrackEncoding><xsl:value-of select="Format"/>
					    <xsl:if test="Format_Version">
						    <xsl:text> </xsl:text><xsl:value-of select="Format_Version"/>
					    </xsl:if>
					    <xsl:if test="Format_Profile">
						    <xsl:text> </xsl:text><xsl:value-of select="Format_Profile"/>
					    </xsl:if>
					    <xsl:if test="Format_Settings_Endianness">
						    <xsl:text> </xsl:text><xsl:value-of select="Format_Settings_Endianness"/><xsl:text>-endian</xsl:text>
					    </xsl:if>
					    <xsl:if test="Format_Settings_Sign">
						    <xsl:text> </xsl:text><xsl:value-of select="Format_Settings_Sign"/>
					    </xsl:if>
					   	<xsl:if test="CodecID and CodecID!=Format">
						    <xsl:text> (</xsl:text><xsl:value-of select="CodecID"/><xsl:text>)</xsl:text>
					    </xsl:if>
					    </essenceTrackEncoding>
				    </xsl:if>
				    
				    <xsl:if test="BitRate">
					    <essenceTrackDataRate><xsl:value-of select="BitRate"/></essenceTrackDataRate>
				    </xsl:if>
				    
				    <xsl:choose>
						<xsl:when test="Delay_Original_String3">
							<essenceTimeStart><xsl:value-of select="Delay_Original_String3"/></essenceTimeStart>
						</xsl:when>
						<xsl:when test="Delay_String3">
							<essenceTimeStart><xsl:value-of select="Delay_String3"/></essenceTimeStart>
						</xsl:when>
					</xsl:choose>
				    
				    <xsl:if test="Duration_String3">
					    <essenceTrackDuration><xsl:value-of select="Duration_String3"/></essenceTrackDuration>
				    </xsl:if>
				    
				    <!-- this is disabled because it is an error. video bitDepth is not necessarily the same of the number of bits used per pixel in a video codec
				    <xsl:choose>
					    <xsl:when test="@type='Video'">
						    <xsl:if test="Bits-_Pixel_Frame_">
							    <essenceTrackBitDepth xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="Bits-_Pixel_Frame_"/></essenceTrackBitDepth>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>-->
							<xsl:if test="Resolution">
								    <essenceTrackBitDepth xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="Resolution"/></essenceTrackBitDepth>
							</xsl:if>
						<!-- </xsl:otherwise>
				    </xsl:choose> -->
				    
				    <xsl:if test="SamplingRate">
					    <essenceTrackSamplingRate xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="SamplingRate"/></essenceTrackSamplingRate>
				    </xsl:if>
				    
				    <xsl:if test="Width">
					    <essenceTrackFrameSize xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="Width"/><xsl:text>X</xsl:text><xsl:value-of select="Height"/></essenceTrackFrameSize>
				    </xsl:if>
				    
				    <xsl:if test="DisplayAspectRatio_String"><!-- AspectRatio as displayed not stored  -->
					    <essenceTrackAspectRatio xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="DisplayAspectRatio_String"/></essenceTrackAspectRatio>
				    </xsl:if>
				    
				    <xsl:if test="FrameRate">
				    <essenceTrackFrameRate xsl:use-attribute-sets="pbcore1.2.1"><xsl:value-of select="FrameRate"/>
					    <!--
					    <xsl:if test="FrameRate_Mode_String"><xsl:text> </xsl:text><xsl:value-of select="FrameRate_Mode_String"/></xsl:if>
					    -->
				    </essenceTrackFrameRate>
				    </xsl:if>
				    
				    <!-- commented out until I have a reliable method to get language as [a-z][a-z][a-z]
				    <essenceTrackLanguage xsl:use-attribute-sets="pbcore1.2.1"></essenceTrackLanguage>
				    -->
				    
				    <xsl:if test="Language">
						<essenceTrackLanguage>
							<xsl:apply-templates select="$langs-top">
								<xsl:with-param name="curr-language" select="Language"/>
							</xsl:apply-templates>
						</essenceTrackLanguage>
					</xsl:if>
				    
				    <essenceTrackAnnotation>
				    
				    <!-- special handling for essenceTrackAnnotation on Colorspace -->
				    <xsl:if test="Colorimetry">
					    <xsl:text>Chroma-subsampling: </xsl:text><xsl:value-of select="Colorimetry"/><xsl:text>&#xa;</xsl:text>
				    </xsl:if>
				    
				    <xsl:if test="Channel_s_">
					    <xsl:text>Channels: </xsl:text><xsl:value-of select="Channel_s_"/><xsl:text>&#xa;</xsl:text>
				    </xsl:if>
				    
				    <xsl:if test="Bits-_Pixel_Frame_">
					    <xsl:text>BitsPerPixel: </xsl:text><xsl:value-of select="Bits-_Pixel_Frame_"/><xsl:text>&#xa;</xsl:text>
				    </xsl:if>
				    
				    <xsl:if test="Delay_Settings">
					    <xsl:text>TimecodeSettings_Container: </xsl:text><xsl:value-of select="Delay_Settings"/><xsl:text>&#xa;</xsl:text>
				    </xsl:if>
				    
				    <xsl:if test="Delay_Original_Settings">
					    <xsl:text>TimecodeSettings_Codec: </xsl:text><xsl:value-of select="Delay_Original_Settings"/><xsl:text>&#xa;</xsl:text>
				    </xsl:if>

				    <!-- unlike annotations of the instantiation element, the essenceTrackAnnotation may only occur once per essenceTrack. This approach excludes MediaInfo values that are mapped elsewhere, depreciated, or redundant and then states the remaining essenceTrack values in a concatenated string within a single essenceTrack element. This produces a very verbose reporting on essenceTrack data, feel free to edit it or completely comment out the xsl:for-each element below and sample from the more inclusive alternate approach below. In the commented out version below MediaInfo values are selected for inclusive rather than taking everything that is not excluded. -->
					    <xsl:for-each select="*">
							<xsl:if test="name(.)!='Count' and name(.)!='StreamCount' and name(.)!='StreamKind' and name(.)!='StreamKind_String' and name(.)!='StreamKindID' and name(.)!='StreamKindPos' and name(.)!='Inform' and name(.)!='ID' and name(.)!='ID_String' and name(.)!='Format_Info' and name(.)!='Format_URL' and name(.)!='Format_Settings_SBR_String' and name(.)!='Format_Settings_PS_String' and name(.)!='Format_Version' and name(.)!='Format_Profile' and name(.)!='CodecID_Info' and name(.)!='CodecID_Hint' and name(.)!='CodecID_Url' and name(.)!='CodecID_Description' and name(.)!='Codec' and name(.)!='Codec_String' and name(.)!='Codec_Family' and name(.)!='Codec_Info' and name(.)!='Codec_Url' and name(.)!='Codec_CC' and name(.)!='Codec_Profile' and name(.)!='Codec_Description' and name(.)!='Codec_Profile' and name(.)!='Codec_Settings' and name(.)!='Codec_Settings_Automatic' and name(.)!='Codec_Settings_Floor' and name(.)!='Codec_Settings_Firm' and name(.)!='Codec_Settings_Endianness' and name(.)!='Codec_Settings_Sign' and name(.)!='Codec_Settings_Law' and name(.)!='Codec_Settings_ITU' and name(.)!='Codec_Settings_BVOP' and name(.)!='Codec_Settings_QPel' and name(.)!='Codec_Settings_GMC' and name(.)!='Codec_Settings_GMC_String' and name(.)!='Codec_Settings_Matrix' and name(.)!='Codec_Settings_Matrix_Data' and name(.)!='Codec_Settings_CABAC' and name(.)!='Codec_Settings_RefFrames' and name(.)!='Duration' and name(.)!='Duration_String' and name(.)!='Duration_String1' and name(.)!='Duration_String2' and name(.)!='Duration_String3' and name(.)!='BitRate_Mode_String' and name(.)!='BitRate' and name(.)!='BitRate_String' and name(.)!='lBitRate_Minimum_String' and name(.)!='BitRate_Nominal_String' and name(.)!='BitRate_Maximum_String' and name(.)!='Channel_s__String' and name(.)!='ChannelPositions_String2' and name(.)!='SamplingRate' and name(.)!='SamplingRate_String' and name(.)!='Width' and name(.)!='Width_String' and name(.)!='Height' and name(.)!='Height_String' and name(.)!='PixelAspectRatio_String' and name(.)!='PixelAspectRatio_Original_String' and name(.)!='DisplayAspectRatio_String' and name(.)!='DisplayAspectRatio_Original_String' and name(.)!='FrameRate' and name(.)!='FrameRate_String' and name(.)!='FrameRate_Minimum_String' and name(.)!='FrameRate_Nominal_String' and name(.)!='FrameRate_Maximum_String' and name(.)!='FrameRate_Original_String' and name(.)!='Resolution' and name(.)!='Resolution_String' and name(.)!='ScanType_String' and name(.)!='ScanOrder_String' and name(.)!='Interlacement' and name(.)!='Interlacement_String' and name(.)!='Delay' and name(.)!='Delay_String' and name(.)!='Delay_String1' and name(.)!='Delay_String2' and name(.)!='Delay_String3' and name(.)!='Delay_Original' and name(.)!='Delay_Original_String' and name(.)!='Delay_Original_String1' and name(.)!='Delay_Original_String2' and name(.)!='Delay_Original_String3' and name(.)!='Video_Delay' and name(.)!='Video_Delay_String' and name(.)!='Video_Delay_String1' and name(.)!='Video_Delay_String2' and name(.)!='Video_Delay_String3' and name(.)!='Video0_Delay' and name(.)!='Video0_Delay_String' and name(.)!='Video0_Delay_String1' and name(.)!='Video0_Delay_String2' and name(.)!='Video0_Delay_String3' and name(.)!='ReplayGain_Gain_String' and name(.)!='Interleave_Duration_String' and name(.)!='Interleave_Preload_String' and name(.)!='StreamSize_String' and name(.)!='StreamSize_String1' and name(.)!='StreamSize_String2' and name(.)!='StreamSize_String3' and name(.)!='StreamSize_String4' and name(.)!='StreamSize_String5' and name(.)!='Alignment_String' and name(.)!='Encoded_Application_Url' and name(.)!='Encoded_Library_String' and name(.)!='Language' and name(.)!='Language_String' and name(.)!='Colorimetry' and name(.)!='Format' and name(.)!='Format_Settings' and name(.)!='Format_Settings_Endianness' and name(.)!='Format_Settings_Sign' and name(.)!='InternetMediaType' and name(.)!='CodecID' and name(.)!='Standard' and name(.)!='FolderName' and name(.)!='Channel_s_' and name(.)!='FrameRate_Mode_String' and name(.)!='Bits-_Pixel_Frame_' and name(.)!='Delay_Settings' and name(.)!='Delay_Original_Settings' and name(.)!='MenuID_String' and name(.)!='Format_Url' and name(.)!='Format_Settings_CABAC_String' and name(.)!='Format_Settings_RefFrames_String' and name(.)!='FrameRate_Mode_String' and name(.)!='Encoded_Library'">   				       		
       				       		<xsl:value-of select="local-name(.)"/><xsl:text>: </xsl:text>
								<xsl:choose>
									<xsl:when test="substring(.,1,3)='UTC' and string-length(.)='23'">
										<xsl:value-of select="substring(.,5,10)"/><xsl:text>T</xsl:text><xsl:value-of select="substring(.,16,8)"/><xsl:text>Z</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>&#xa;</xsl:text>
						    </xsl:if>
						</xsl:for-each>
				    </essenceTrackAnnotation>
				  </pbcoreEssenceTrack>
				</xsl:for-each>
				<!-- annotations: there seems to be 2 ways to go about handling annotations in a MediaInfo to pbcore-instantiation workflow: 1). inclusive and 2). exclusive. The below method goes with an exclusive approach where MediaInfo values that aren't specifically mapped elsewhere are retained while depreciated and redundant values are also excluded. Feel free to tinker with the test attribute in the xsl:if element to adjust the verbosity. An alternate inclusive approach is commented out just below this. -->
				<xsl:for-each select="track[@type='General']">

					<xsl:if test="Format"><!-- formatStandard is depreciated in PBCore 1.2.1 so there is no clear place to document the media container, ie. Quicktime, MP4, etc, so this is done specifically as an annotation -->
						<pbcoreAnnotation>
					        <annotation>
					       		<xsl:text>Container: </xsl:text><xsl:value-of select="Format"/>
					       		<xsl:if test="Format_Version">
								    <xsl:text> </xsl:text><xsl:value-of select="Format_Version"/>
							    </xsl:if>
							    <xsl:if test="Format_Profile">
								    <xsl:text> </xsl:text><xsl:value-of select="Format_Profile"/>
							    </xsl:if>
							   	<xsl:if test="CodecID"><!-- fourcc codes are helpful but don't have an explicit location in pbcore. Current these are stored parathetically within essenceTrackEncoding and 'Container' annotations but potentially these could be handled separately as their own annotation. -->
								    <xsl:text> (</xsl:text><xsl:value-of select="CodecID"/><xsl:text>)</xsl:text>
							    </xsl:if>
							</annotation>
						</pbcoreAnnotation>
					</xsl:if>
					
					<xsl:for-each select="*">
						<xsl:if test="name(.)!='Count' and name(.)!='StreamCount' and name(.)!='StreamKind' and name(.)!='StreamKind_String' and name(.)!='StreamKindID' and name(.)!='StreamKindPos' and name(.)!='Inform' and name(.)!='ID_String' and name(.)!='UniqueID_String' and name(.)!='GeneralCount' and name(.)!='VideoCount' and name(.)!='AudioCount' and name(.)!='TextCount' and name(.)!='ChaptersCount' and name(.)!='ImageCount' and name(.)!='MenuCount' and name(.)!='Video_Format_List' and name(.)!='Video_Language_List' and name(.)!='Video_Format_WithHint_List' and name(.)!='Video_Codec_List' and name(.)!='Audio_Format_List' and name(.)!='Audio_Language_List' and name(.)!='Audio_Format_WithHint_List' and name(.)!='Audio_Codec_List' and name(.)!='Text_Format_List' and name(.)!='Text_Language_List' and name(.)!='Text_Format_WithHint_List' and name(.)!='Text_Codec_List' and name(.)!='Chapters_Format_List' and name(.)!='Chapters_Language_List' and name(.)!='Chapters_Format_WithHint_List' and name(.)!='Chapters_Codec_List' and name(.)!='Image_Format_List' and name(.)!='Image_Language_List' and name(.)!='Image_Format_WithHint_List' and name(.)!='Image_Codec_List' and name(.)!='Menu_Format_List' and name(.)!='Menu_Language_List' and name(.)!='Menu_Format_WithHint_List' and name(.)!='Menu_Codec_List' and name(.)!='FileName' and name(.)!='Format' and name(.)!='Format_Extensions' and name(.)!='Format_Version' and name(.)!='Format_Profile' and name(.)!='Format_String' and name(.)!='Format_Url' and name(.)!='CodecID' and name(.)!='Codec' and name(.)!='Codec_String' and name(.)!='Codec_Info' and name(.)!='Codec_Url' and name(.)!='CodecID_Url' and name(.)!='Codec_Extensions' and name(.)!='Codec_Settings' and name(.)!='Codec_Settings_Automatic' and name(.)!='OriginalSourceMedium' and name(.)!='com.apple.finalcutstudio.media.uuid' and name(.)!='Recorded_Date' and name(.)!='CompleteName' and name(.)!='FileSize' and name(.)!='FileSize_String' and name(.)!='FileSize_String1' and name(.)!='FileSize_String2' and name(.)!='FileSize_String3' and name(.)!='FileSize_String4' and name(.)!='Delay_Original_String3' and name(.)!='Delay_String3' and name(.)!='Duration' and name(.)!='Duration_String' and name(.)!='Duration_String1' and name(.)!='Duration_String2' and name(.)!='Duration_String3' and name(.)!='OverallBitRate_Mode_String' and name(.)!='OverallBitRate' and name(.)!='OverallBitRate_String' and name(.)!='OverallBitRate_Minimum_String' and name(.)!='OverallBitRate_Nominal_String' and name(.)!='OverallBitRate_Maximum_String' and name(.)!='StreamSize' and name(.)!='StreamSize_Proportion' and name(.)!='StreamSize_String' and name(.)!='StreamSize_String1' and name(.)!='StreamSize_String2' and name(.)!='StreamSize_String3' and name(.)!='StreamSize_String4' and name(.)!='StreamSize_String5' and name(.)!='com.apple.quicktime.player.movie.audio.mute' and name(.)!='Encoded_Library_String' and name(.)!='Encoded_Library_Name' and name(.)!='Encoded_Library_Version' and name(.)!='Cover_Data' and name(.)!='Language' and name(.)!='Language_String' and name(.)!='InternetMediaType' and name(.)!='FileExtension' and name(.)!='Media_UUID' and name(.)!='Media_History_UUID' and name(.)!='FolderName'">
						    <pbcoreAnnotation>
						        <annotation>       		
							       	<xsl:value-of select="local-name(.)"/><xsl:text>: </xsl:text><!-- the annotation as named by MediaInfo's raw output -->				    
									<xsl:choose>
										<xsl:when test="substring(.,1,3)='UTC' and string-length(.)='23'">
											<xsl:value-of select="substring(.,5,10)"/><xsl:text>T</xsl:text><xsl:value-of select="substring(.,16,8)"/><xsl:text>Z</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="."/>
										</xsl:otherwise>
									</xsl:choose>
								</annotation>
						    </pbcoreAnnotation>
					    </xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</pbcoreInstantiation>
		</xsl:for-each>	
	</xsl:template>	
	
	<xsl:template match="la:langs">
		<xsl:param name="curr-language"/>
		<xsl:value-of select="key('lang-lookup', $curr-language)/@two"/>
	</xsl:template>
	
	<la:langs>
		<la:lang one="aa" two="aar"/>		<la:lang one="ab" two="abk"/>		<la:lang one="ae" two="ave"/>		<la:lang one="af" two="afr"/>		<la:lang one="ak" two="aka"/>		<la:lang one="am" two="amh"/>		<la:lang one="an" two="arg"/>		<la:lang one="ar" two="ara"/>		<la:lang one="as" two="asm"/>		<la:lang one="av" two="ava"/>		<la:lang one="ay" two="aym"/>		<la:lang one="az" two="aze"/>		<la:lang one="ba" two="bak"/>		<la:lang one="be" two="bel"/>		<la:lang one="bg" two="bul"/>		<la:lang one="bh" two="bih"/>		<la:lang one="bi" two="bis"/>		<la:lang one="bm" two="bam"/>		<la:lang one="bn" two="ben"/>		<la:lang one="bo" two="tib"/>		<la:lang one="br" two="bre"/>		<la:lang one="bs" two="bos"/>		<la:lang one="ca" two="cat"/>		<la:lang one="ce" two="che"/>		<la:lang one="ch" two="cha"/>		<la:lang one="co" two="cos"/>		<la:lang one="cr" two="cre"/>		<la:lang one="cs" two="cze"/>		<la:lang one="cu" two="chu"/>		<la:lang one="cv" two="chv"/>		<la:lang one="cy" two="wel"/>		<la:lang one="da" two="dan"/>		<la:lang one="de" two="ger"/>		<la:lang one="dv" two="div"/>		<la:lang one="dz" two="dzo"/>		<la:lang one="ee" two="ewe"/>		<la:lang one="el" two="gre"/>		<la:lang one="en" two="eng"/>		<la:lang one="eo" two="epo"/>		<la:lang one="es" two="spa"/>		<la:lang one="et" two="est"/>		<la:lang one="eu" two="baq"/>		<la:lang one="fa" two="per"/>		<la:lang one="ff" two="ful"/>		<la:lang one="fi" two="fin"/>		<la:lang one="fj" two="fij"/>		<la:lang one="fo" two="fao"/>		<la:lang one="fr" two="fre"/>		<la:lang one="fy" two="fry"/>		<la:lang one="ga" two="gle"/>		<la:lang one="gd" two="gla"/>		<la:lang one="gl" two="glg"/>		<la:lang one="gn" two="grn"/>		<la:lang one="gu" two="guj"/>		<la:lang one="gv" two="glv"/>		<la:lang one="ha" two="hau"/>		<la:lang one="he" two="heb"/>		<la:lang one="hi" two="hin"/>		<la:lang one="ho" two="hmo"/>		<la:lang one="hr" two="hrv"/>		<la:lang one="ht" two="hat"/>		<la:lang one="hu" two="hun"/>		<la:lang one="hy" two="arm"/>		<la:lang one="hz" two="her"/>		<la:lang one="ia" two="ina"/>		<la:lang one="id" two="ind"/>		<la:lang one="ie" two="ile"/>		<la:lang one="ig" two="ibo"/>		<la:lang one="ii" two="iii"/>		<la:lang one="ik" two="ipk"/>		<la:lang one="io" two="ido"/>		<la:lang one="is" two="ice"/>		<la:lang one="it" two="ita"/>		<la:lang one="iu" two="iku"/>		<la:lang one="ja" two="jpn"/>		<la:lang one="jv" two="jav"/>		<la:lang one="ka" two="geo"/>		<la:lang one="kg" two="kon"/>		<la:lang one="ki" two="kik"/>		<la:lang one="kj" two="kua"/>		<la:lang one="kk" two="kaz"/>		<la:lang one="kl" two="kal"/>		<la:lang one="km" two="khm"/>		<la:lang one="kn" two="kan"/>		<la:lang one="ko" two="kor"/>		<la:lang one="kr" two="kau"/>		<la:lang one="ks" two="kas"/>		<la:lang one="ku" two="kur"/>		<la:lang one="kv" two="kom"/>		<la:lang one="kw" two="cor"/>		<la:lang one="ky" two="kir"/>		<la:lang one="la" two="lat"/>		<la:lang one="lb" two="ltz"/>		<la:lang one="lg" two="lug"/>		<la:lang one="li" two="lim"/>		<la:lang one="ln" two="lin"/>		<la:lang one="lo" two="lao"/>		<la:lang one="lt" two="lit"/>		<la:lang one="lu" two="lub"/>		<la:lang one="lv" two="lav"/>		<la:lang one="mg" two="mlg"/>		<la:lang one="mh" two="mah"/>		<la:lang one="mi" two="mao"/>		<la:lang one="mk" two="mac"/>		<la:lang one="ml" two="mal"/>		<la:lang one="mn" two="mon"/>		<la:lang one="mr" two="mar"/>		<la:lang one="ms" two="may"/>		<la:lang one="mt" two="mlt"/>		<la:lang one="my" two="bur"/>		<la:lang one="na" two="nau"/>		<la:lang one="nb" two="nob"/>		<la:lang one="nd" two="nde"/>		<la:lang one="ne" two="nep"/>		<la:lang one="ng" two="ndo"/>		<la:lang one="nl" two="dut"/>		<la:lang one="nn" two="nno"/>		<la:lang one="no" two="nor"/>		<la:lang one="nr" two="nbl"/>		<la:lang one="nv" two="nav"/>		<la:lang one="ny" two="nya"/>		<la:lang one="oc" two="oci"/>		<la:lang one="oj" two="oji"/>		<la:lang one="om" two="orm"/>		<la:lang one="or" two="ori"/>		<la:lang one="os" two="oss"/>		<la:lang one="pa" two="pan"/>		<la:lang one="pi" two="pli"/>		<la:lang one="pl" two="pol"/>		<la:lang one="ps" two="pus"/>		<la:lang one="pt" two="por"/>		<la:lang one="qu" two="que"/>		<la:lang one="rm" two="roh"/>		<la:lang one="rn" two="run"/>		<la:lang one="ro" two="rum"/>		<la:lang one="ru" two="rus"/>		<la:lang one="rw" two="kin"/>		<la:lang one="sa" two="san"/>		<la:lang one="sc" two="srd"/>		<la:lang one="sd" two="snd"/>		<la:lang one="se" two="sme"/>		<la:lang one="sg" two="sag"/>		<la:lang one="si" two="sin"/>		<la:lang one="sk" two="slo"/>		<la:lang one="sl" two="slv"/>		<la:lang one="sm" two="smo"/>		<la:lang one="sn" two="sna"/>		<la:lang one="so" two="som"/>		<la:lang one="sq" two="alb"/>		<la:lang one="sr" two="srp"/>		<la:lang one="ss" two="ssw"/>		<la:lang one="st" two="sot"/>		<la:lang one="su" two="sun"/>		<la:lang one="sv" two="swe"/>		<la:lang one="sw" two="swa"/>		<la:lang one="ta" two="tam"/>		<la:lang one="te" two="tel"/>		<la:lang one="tg" two="tgk"/>		<la:lang one="th" two="tha"/>		<la:lang one="ti" two="tir"/>		<la:lang one="tk" two="tuk"/>		<la:lang one="tl" two="tgl"/>		<la:lang one="tn" two="tsn"/>		<la:lang one="to" two="ton"/>		<la:lang one="tr" two="tur"/>		<la:lang one="ts" two="tso"/>		<la:lang one="tt" two="tat"/>		<la:lang one="tw" two="twi"/>		<la:lang one="ty" two="tah"/>		<la:lang one="ug" two="uig"/>		<la:lang one="uk" two="ukr"/>		<la:lang one="ur" two="urd"/>		<la:lang one="uz" two="uzb"/>		<la:lang one="ve" two="ven"/>		<la:lang one="vi" two="vie"/>		<la:lang one="vo" two="vol"/>		<la:lang one="wa" two="wln"/>		<la:lang one="wo" two="wol"/>		<la:lang one="xh" two="xho"/>		<la:lang one="yi" two="yid"/>		<la:lang one="yo" two="yor"/>		<la:lang one="za" two="zha"/>		<la:lang one="zh" two="chi"/>		<la:lang one="zu" two="zul"/>
	</la:langs>
	
</xsl:stylesheet>
